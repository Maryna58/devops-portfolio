package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

var fileCategories = map[string]string{
	".jpg": "Images", ".jpeg": "Images", ".png": "Images",
	".mp4": "Videos", ".mkv": "Videos",
	".mp3": "Music",
	".pdf": "Docs", ".docx": "Docs", ".doc": "Docs", ".txt": "Docs",
	".zip": "Archives", ".rar": "Archives",
	".py": "Code", ".go": "Code", ".js": "Code", ".html": "Code", ".css": "Code", ".json": "Code",
}

func organizeFiles(src string, dry bool) {
	filepath.Walk(src, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if !info.IsDir() {
			if info.Name() == "main.go" || strings.HasPrefix(info.Name(), ".") {
				return nil
			}

			ext := strings.ToLower(filepath.Ext(path))
			folder, exists := fileCategories[ext]
			if !exists {
				folder = "Others"
			}

			destFolder := filepath.Join(src, folder)
			dest := filepath.Join(destFolder, info.Name())

			if path == dest {
				return nil
			}

			if dry {
				fmt.Println("Would move:", path, "->", dest)
			} else {
				os.MkdirAll(destFolder, os.ModePerm)
				err := os.Rename(path, dest)
				if err != nil {
					fmt.Println("Error moving:", path, "->", err)
				} else {
					fmt.Println("Moved:", info.Name(), "->", folder)
				}
			}
		}
		return nil
	})
}

func main() {
	srcDir := flag.String("src", ".", "Source directory to organize")
	dryRun := flag.Bool("dry", false, "Run without making changes")
	flag.Parse()

	fmt.Println("Source dir:", *srcDir)
	fmt.Println("Dry run:", *dryRun)

	organizeFiles(*srcDir, *dryRun)
}
