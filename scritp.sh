#!/bin/bash

# Fonction pour comparer la sortie de my-ls-1 avec ls
compare_outputs() {
    local description="$1"
    local command_ls="$2"
    local command_my_ls="$3"

    echo "\n=== Test: $description ==="
    echo "$command_ls" > output_ls.txt
    echo "$command_my_ls" > output_my_ls.txt

    diff -u <($command_ls) <($command_my_ls) > diff_output.txt

    if [ $? -eq 0 ]; then
        echo "[PASS] $description"
    else
        echo "[FAIL] $description"
        echo "Diff:" && cat diff_output.txt
    fi

    rm -f output_ls.txt output_my_ls.txt diff_output.txt
}

# Tests simples
compare_outputs "Afficher le répertoire courant" \
    "ls" "./my-ls-1"

compare_outputs "Afficher un fichier" \
    "ls testfile" "./my-ls-1 testfile"

compare_outputs "Afficher un répertoire" \
    "ls testdir" "./my-ls-1 testdir"

# Tests avec options
compare_outputs "Format long (-l)" \
    "ls -l" "./my-ls-1 -l"

compare_outputs "Tous les fichiers (-a)" \
    "ls -a" "./my-ls-1 -a"

compare_outputs "Récursivité (-R)" \
    "ls -R testdir" "./my-ls-1 -R testdir"

compare_outputs "Tri par date (-t)" \
    "ls -t" "./my-ls-1 -t"

compare_outputs "Ordre inversé (-r)" \
    "ls -r" "./my-ls-1 -r"

compare_outputs "Combinaison (-la)" \
    "ls -la" "./my-ls-1 -la"

compare_outputs "Combinaison (-lRr)" \
    "ls -lRr testdir" "./my-ls-1 -lRr testdir"

# Cas complexes
compare_outputs "Chemin complexe (-lR)" \
    "ls -lR testdir///subdir///" "./my-ls-1 -lR testdir///subdir///"

compare_outputs "Afficher /dev (-la)" \
    "ls -la /dev" "./my-ls-1 -la /dev"

# Liens symboliques
ln -s testfile symlink_test
ln -s testdir symlink_dir

compare_outputs "Lien symbolique fichier (-l)" \
    "ls -l symlink_test" "./my-ls-1 -l symlink_test"

compare_outputs "Lien symbolique répertoire (-l)" \
    "ls -l symlink_dir" "./my-ls-1 -l symlink_dir"

compare_outputs "Lien symbolique répertoire avec / (-l)" \
    "ls -l symlink_dir/" "./my-ls-1 -l symlink_dir/"

# Nettoyage des liens symboliques
rm -f symlink_test symlink_dir

# Performance
echo "\n=== Test de performance ==="
time ./my-ls-1 -R ~
