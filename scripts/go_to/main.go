package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

var fileTypes = map[string]string{
	".jpg":  "Images",
	".jpeg": "Images",
	".mp4":  "Videos",
	".pdf":  "Documents",
	".docx": "Documents",
	".txt":  "Documents",
	".zip":  "Archives",
	".py":   "Code",
	".go":   "Code",
	".js":   "Code",
	".html": "Code",
}

func main() {
	dirPtr := flag.String("path", ".", "Path to the directory to organize")
	dryRunPtr := flag.Bool("dry-run", false, "Show what would be done without actually moving files")
	flag.Parse()

	targetDir := *dirPtr
	fmt.Printf("Analyzing directory: %s\n", targetDir)


	files, err := os.ReadDir(targetDir)
	if err != nil {
		fmt.Printf(" Error reading directory: %v\n", err)
		os.Exit(1)
	}

	for _, file := range files {
		if file.IsDir() {
			continue
		}

		fileName := file.Name()
		ext := strings.ToLower(filepath.Ext(fileName))

		category, exists := fileTypes[ext]
		if !exists {
			category = "Others"
		}

		destFolder := filepath.Join(targetDir, category)
		sourcePath := filepath.Join(targetDir, fileName)
		destPath := filepath.Join(destFolder, fileName)

		if *dryRunPtr {
			fmt.Printf("[Dry Run] Move '%s' -> '%s'\n", fileName, category)
		} else {
			if _, err := os.Stat(destFolder); os.IsNotExist(err) {
				os.Mkdir(destFolder, 0755)
			}

			err := os.Rename(sourcePath, destPath)
			if err != nil {
				fmt.Printf(" Error moving %s: %v\n", fileName, err)
			} else {
				fmt.Printf(" Moved: %s -> %s/\n", fileName, category)
			}
		}
	}
	fmt.Println("🎉 Done!")
}