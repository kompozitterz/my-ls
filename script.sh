#!/bin/bash

# Fonction pour comparer la sortie de my-ls avec ls
compare_outputs() {
    local description="$1"
    local command_ls="$2"
    local command_my_ls="$3"

    echo -e "\n=== Test: $description ==="
    eval "$command_ls" > output_ls.txt
    eval "$command_my_ls" > output_my_ls.txt

    diff -u output_ls.txt output_my_ls.txt > diff_output.txt

    if [ $? -eq 0 ]; then
        echo "[PASS] $description"
    else
        # echo "[FAIL] $description"
        echo "Diff:" && cat diff_output.txt
    fi

    rm -f output_ls.txt output_my_ls.txt diff_output.txt
}

# Création d'un environnement de test local
mkdir -p testdir/subdir
touch testfile
touch testdir/file_in_dir
ln -s testfile symlink_test
ln -s testdir symlink_dir

# Tests simples
compare_outputs "Afficher le répertoire courant" \
    "ls" "./my-ls"

compare_outputs "Afficher un fichier" \
    "ls testfile" "./my-ls testfile"

compare_outputs "Afficher un répertoire" \
    "ls testdir" "./my-ls testdir"

# Tests avec options
compare_outputs "Format long (-l)" \
    "ls -l" "./my-ls -l"

compare_outputs "Tous les fichiers (-a)" \
    "ls -a" "./my-ls -a"

compare_outputs "Récursivité (-R)" \
    "ls -R testdir" "./my-ls -R testdir"

compare_outputs "Tri par date (-t)" \
    "ls -t" "./my-ls -t"

compare_outputs "Ordre inversé (-r)" \
    "ls -r" "./my-ls -r"

compare_outputs "Combinaison (-la)" \
    "ls -la" "./my-ls -la"

compare_outputs "Combinaison (-lRr)" \
    "ls -lRr testdir" "./my-ls -lRr testdir"

# Cas complexes
compare_outputs "Chemin complexe (-lR)" \
    "ls -lR testdir/subdir/" "./my-ls -lR testdir/subdir/"

# Liens symboliques
compare_outputs "Lien symbolique fichier (-l)" \
    "ls -l symlink_test" "./my-ls -l symlink_test"

compare_outputs "Lien symbolique répertoire (-l)" \
    "ls -l symlink_dir" "./my-ls -l symlink_dir"

compare_outputs "Lien symbolique répertoire avec / (-l)" \
    "ls -l symlink_dir/" "./my-ls -l symlink_dir/"

# Nettoyage des fichiers et répertoires temporaires
rm -rf testdir symlink_test symlink_dir testfile
