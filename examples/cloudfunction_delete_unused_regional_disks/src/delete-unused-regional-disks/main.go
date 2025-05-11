package function

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"

	// Google Cloud Compute client libraries
	compute "cloud.google.com/go/compute/apiv1"
	computepb "cloud.google.com/go/compute/apiv1/computepb"
	"google.golang.org/api/iterator" // Helps loop through items returned from API
)

func DeleteUnusedRegionalDisks(w http.ResponseWriter, r *http.Request) {
	ctx := context.Background() // Create a context for the API calls

	projectID := os.Getenv("PROJECT") // Get project ID from environment variable
	region := os.Getenv("REGION")     // Get region from environment variable

	// Make sure both variables are set
	if projectID == "" || region == "" {
		log.Fatal("Both PROJECT and REGION environment variables must be set")
	}

	// Create a client to work with regional disks
	regionalDisksClient, err := compute.NewRegionDisksRESTClient(ctx)
	if err != nil {
		log.Fatalf("Failed to create regional disks client: %v", err) // Stop if there's an error
	}
	defer regionalDisksClient.Close() // Close client when done

	// Create a request to list all regional disks in this region
	req := &computepb.ListRegionDisksRequest{
		Project: projectID,
		Region:  region,
	}

	// Get an iterator to go through all regional disks
	it := regionalDisksClient.List(ctx, req)
	for {
		// Get the next disk in the list
		disk, err := it.Next()
		if err == iterator.Done {
			break // No more disks, so stop the loop
		}
		if err != nil {
			log.Fatalf("Error listing regional disks: %v", err) // Stop if error
		}

		// Check if the disk is unused (no users)
		if len(disk.GetUsers()) == 0 {
			// Print info about this unused disk
			fmt.Printf("Unused Regional Disk: %s, Size: %d GB, Type: %s, Status: %s\n",
				disk.GetName(),
				disk.GetSizeGb(),
				extractType(disk.GetType()),
				disk.GetStatus())

			// Create a request to delete this disk
			deleteReq := &computepb.DeleteRegionDiskRequest{
				Project: projectID,
				Region:  region,
				Disk:    disk.GetName(),
			}

			// Send the delete request
			op, err := regionalDisksClient.Delete(ctx, deleteReq)
			if err != nil {
				// Print error if delete failed
				log.Printf("Failed to delete regional disk %s: %v", disk.GetName(), err)
			} else {
				// Print success message with operation name
				log.Printf("Delete request submitted for regional disk: %s (operation: %s)",
					disk.GetName(), op.Proto().GetName())
			}
		}
	}
}

// This helper function takes a URL like ".../pd-balanced" and returns "pd-balanced"
func extractType(fullType string) string {
	parts := strings.Split(fullType, "/") // Split by "/"
	if len(parts) > 0 {
		return parts[len(parts)-1] // Return the last part
	}
	return fullType
}