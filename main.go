package main

import (
	"flag"
	"fmt"
	"io/fs"
	"os"
	"sort"
	"strings"
	"syscall"
)

const (
	resetColor   = "\033[0m"
	dirColor     = "\033[1;34m"
	symlinkColor = "\033[1;36m"
)

func getColor(file fs.FileInfo) string {
	if file.IsDir() {
		return dirColor
	}
	if file.Mode()&fs.ModeSymlink != 0 {
		return symlinkColor
	}
	return resetColor
}

func formatPermissions(mode fs.FileMode) string {
	perms := ""
	if mode.IsDir() {
		perms += "d"
	} else {
		perms += "-"
	}
	perms += mode.String()[1:]
	return perms
}

func reverseSlice(files []fs.FileInfo) {
	for i, j := 0, len(files)-1; i < j; i, j = i+1, j-1 {
		files[i], files[j] = files[j], files[i]
	}
}

func list(path string, r, l, a, rev, t bool) {
	d, err := os.ReadDir(path)
	if err != nil {
		fmt.Printf("Erreur lors de la lecture du répertoire %s: %v\n", path, err)
		return
	}

	var files []fs.FileInfo
	for _, entry := range d {
		if !a && strings.HasPrefix(entry.Name(), ".") {
			continue
		}
		info, err := entry.Info()
		if err != nil {
			fmt.Printf("Erreur lors de l'obtention des informations sur le fichier %s: %v\n", entry.Name(), err)
			continue
		}
		files = append(files, info)
	}

	// Sorting logic
	if t {
		sort.Slice(files, func(i, j int) bool {
			return files[i].ModTime().After(files[j].ModTime())
		})
	} else {
		sort.Slice(files, func(i, j int) bool {
			return files[i].Name() < files[j].Name()
		})
	}

	if rev {
		reverseSlice(files)
	}

	// Display files
	for _, file := range files {
		color := getColor(file)
		if l {
			stat, ok := file.Sys().(*syscall.Stat_t)
			if !ok {
				fmt.Printf("Impossible de récupérer les informations de %s\n", file.Name())
				continue
			}
			fmt.Printf("%s%-10s %3d %6d %6d %12d %s %s%s\n",
				color,
				formatPermissions(file.Mode()),
				stat.Nlink,
				stat.Uid,
				stat.Gid,
				file.Size(),
				file.ModTime().Format("Jan 02 15:04"),
				file.Name(),
				resetColor,
			)
		} else {
			fmt.Printf("%s%s\t%s", color, file.Name(), resetColor)
		}
		if r && file.IsDir() {
			fmt.Println()
			list(fmt.Sprintf("%s/%s", path, file.Name()), r, l, a, rev, t)
		}
	}
	if !l {
		fmt.Println()
	}
}

func main() {
	r := flag.Bool("R", false, "Afficher récursivement le contenu des sous-répertoires")
	l := flag.Bool("l", false, "Utiliser le format d'affichage long")
	a := flag.Bool("a", false, "Afficher les fichiers cachés")
	rev := flag.Bool("r", false, "Inverser l'ordre du tri")
	t := flag.Bool("t", false, "Trier par date de modification")
	flag.Parse()
	args := flag.Args()

	if len(args) == 0 {
		list(".", *r, *l, *a, *rev, *t)
	} else {
		for _, arg := range args {
			fileInfo, err := os.Stat(arg)
			if err != nil {
				fmt.Printf("Erreur : %v\n", err)
				continue
			}

			if fileInfo.IsDir() {
				fmt.Printf("%s:\n", arg)
				list(arg, *r, *l, *a, *rev, *t)
			} else {
				color := getColor(fileInfo)
				if *l {
					stat, ok := fileInfo.Sys().(*syscall.Stat_t)
					if !ok {
						fmt.Printf("Impossible de récupérer les informations de %s\n", fileInfo.Name())
						continue
					}
					fmt.Printf("%s%-10s %3d %6d %6d %12d %s %s%s\n",
						color,
						formatPermissions(fileInfo.Mode()),
						stat.Nlink,
						stat.Uid,
						stat.Gid,
						fileInfo.Size(),
						fileInfo.ModTime().Format("Jan 02 15:04"),
						fileInfo.Name(),
						resetColor,
					)
				} else {
					fmt.Printf("%s%s\t%s\n", color, fileInfo.Name(), resetColor)
				}
			}
		}
	}
}
