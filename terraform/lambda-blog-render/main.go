package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
)

func handler(ctx context.Context, s3Event events.S3Event) {
	for _, record := range s3Event.Records {
		s3 := record.S3
		fmt.Printf("[%s - %s] Bucket = %s, Key = %s \n", record.EventSource, record.EventTime, s3.Bucket.Name, s3.Object.Key)
		/*
			Processing rules:
			- drafts/*.md: render the draft
			- posts/*.md: render the post, archive, index, and date indexes (yearly, monthly)
			- templates/*: render everything
			- public/*: copy to the public bucket
			- anything else: warning or error?

			Public bucket structure:
			- index.html
			- feed.xml
			- feed.json
			- archive/index.html
			- posts/yyyy/index.html
			- posts/yyyy/mm/{slug}.html
		*/
	}
}

func main() {
	lambda.Start(handler)
}
