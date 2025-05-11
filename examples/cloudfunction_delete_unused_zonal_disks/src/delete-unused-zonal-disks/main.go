/*
© 2025 Dushan Wijesinghe - Licensed under the MIT License.

You’re welcome to use, modify, and contribute improvements.
Please keep contributions aligned with the original example.
*/

package function

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"

	compute "cloud.google.com/go/compute/apiv1"
	computepb "cloud.google.com/go/compute/apiv1/computepb"
	"google.golang.org/api/iterator"
)

/*
This function checks for unused (unattached) disks in all zones of
a given region, and deletes them if they are not in use.*/
func DeleteUnusedZonalDisks(w http.ResponseWriter, r *http.Request) {
	ctx := context.Background()

	// Read project ID and region from environment variables
	projectID := os.Getenv("PROJECT")
	region := os.Getenv("REGION")

	// Make sure both environment variables are provided
	if projectID == "" || region == "" {
		log.Fatal("Both PROJECT and REGION environment variables must be set")
	}

	// Create a client to get region information
	regionsClient, err := compute.NewRegionsRESTClient(ctx)
	if err != nil {
		log.Fatalf("Failed to create regions client: %v", err)
	}
	defer regionsClient.Close()

	// Request region details using the client
	regionReq := &computepb.GetRegionRequest{
		Project: projectID,
		Region:  region,
	}

	regionResp, err := regionsClient.Get(ctx, regionReq)
	if err != nil {
		log.Fatalf("Failed to get region info: %v", err)
	}

	// Extract zone names from the region response
	var zones []string
	for _, zoneURL := range regionResp.GetZones() {
		parts := strings.Split(zoneURL, "/")
		zoneName := parts[len(parts)-1]
		zones = append(zones, zoneName)
	}
	fmt.Printf("Zones in region %s: %v\n\n", region, zones)

	// Create a client to work with disks
	disksClient, err := compute.NewDisksRESTClient(ctx)
	if err != nil {
		log.Fatalf("Failed to create disks client: %v", err)
	}
	defer disksClient.Close()

	// Loop through all zones in the region
	for _, zone := range zones {
		fmt.Printf("Checking zone: %s\n", zone)

		// Create a request to list all disks in the current zone
		req := &computepb.ListDisksRequest{
			Project: projectID,
			Zone:    zone,
		}

		// Use an iterator to go through each disk
		it := disksClient.List(ctx, req)
		for {
			disk, err := it.Next()
			if err == iterator.Done {
				break // No more disks to check
			}
			if err != nil {
				log.Fatalf("Error retrieving disks in zone %s: %v", zone, err)
			}

			// If the disk has no users, it's considered unused
			if len(disk.GetUsers()) == 0 {
				// Print info about the unused disk
				fmt.Printf("Unused Disk: %s, Size: %d GB, Type: %s, Status: %s\n",
					disk.GetName(), disk.GetSizeGb(), extractType(disk.GetType()), disk.GetStatus())

				// Create a request to delete the unused disk
				deleteReq := &computepb.DeleteDiskRequest{
					Project: projectID,
					Zone:    zone,
					Disk:    disk.GetName(),
				}

				// Try to delete the disk
				op, err := disksClient.Delete(ctx, deleteReq)
				if err != nil {
					// Log if there was an error deleting the disk
					log.Printf("Failed to delete disk %s in zone %s: %v", disk.GetName(), zone, err)
				} else {
					// Log success message with operation ID
					log.Printf("Delete request submitted for disk: %s in zone: %s (operation: %s)",
						disk.GetName(), zone, op.Proto().GetName())
				}
			}
		}
	}
}

// This helper function extracts the disk type from the full URI
func extractType(fullType string) string {
	parts := strings.Split(fullType, "/")
	if len(parts) > 0 {
		return parts[len(parts)-1] // Get the last part of the URI
	}
	return fullType
}