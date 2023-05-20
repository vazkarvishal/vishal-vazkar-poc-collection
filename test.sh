for dir in $(find . -type d -name '??-??-????-*'); do
    name=$(basename "$dir" | sed -r 's/..-..-....-(.*)/\1/')
    date=$(basename "$dir" | sed -r 's/(..)-(..)-(....)-.*/\3-\2-\1/')
    mv "$dir" "$(dirname "$dir")/$name-$date"
done
