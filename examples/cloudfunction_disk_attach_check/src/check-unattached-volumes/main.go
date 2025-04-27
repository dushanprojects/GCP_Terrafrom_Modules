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

func CheckUnattachedVolumes(w http.ResponseWriter, r *http.Request) {
	ctx := context.Background()

	projectID := os.Getenv("PROJECT")
	region := os.Getenv("REGION")

	if projectID == "" || region == "" {
		log.Fatal("Both PROJECT and REGION environment variables must be set")
	}

	// Get list of zones for the region
	regionsClient, err := compute.NewRegionsRESTClient(ctx)
	if err != nil {
		log.Fatalf("Failed to create regions client: %v", err)
	}
	defer regionsClient.Close()

	regionReq := &computepb.GetRegionRequest{
		Project: projectID,
		Region:  region,
	}

	regionResp, err := regionsClient.Get(ctx, regionReq)
	if err != nil {
		log.Fatalf("Failed to get region info: %v", err)
	}

	var zones []string
	for _, zoneURL := range regionResp.GetZones() {
		parts := strings.Split(zoneURL, "/")
		zoneName := parts[len(parts)-1]
		zones = append(zones, zoneName)
	}
	fmt.Printf("Zones in region %s: %v\n\n", region, zones)

	// Create the disks client
	disksClient, err := compute.NewDisksRESTClient(ctx)
	if err != nil {
		log.Fatalf("Failed to create disks client: %v", err)
	}
	defer disksClient.Close()

	// Iterate over each zone and list disks
	for _, zone := range zones {
		fmt.Printf("Checking zone: %s\n", zone)

		req := &computepb.ListDisksRequest{
			Project: projectID,
			Zone:    zone,
		}

		it := disksClient.List(ctx, req)
		for {
			disk, err := it.Next()
			if err == iterator.Done {
				break
			}
			if err != nil {
				log.Fatalf("Error retrieving disks in zone %s: %v", zone, err)
			}

			// Show disks that are not in use
			if len(disk.GetUsers()) == 0 {
				fmt.Printf("Unused Disk: %s, Size: %d GB, Type: %s, Status: %s\n",
					disk.GetName(), disk.GetSizeGb(), extractType(disk.GetType()), disk.GetStatus())
					
				// Add your email or Slack notification actions here
			}
		}
	}
}

// Extract disk type from full URI
func extractType(fullType string) string {
	parts := strings.Split(fullType, "/")
	if len(parts) > 0 {
		return parts[len(parts)-1]
	}
	return fullType
}