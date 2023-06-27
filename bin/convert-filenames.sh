#!/usr/bin/env bash
# Clyhtsuriva

# Check if file arguments are provided
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <file1> [<file2> ...]"
  exit 1
fi

# Loop through all file arguments
for file in "$@"; do
  # Check if the file exists
  if [ ! -f "$file" ]; then
    echo "File '$file' does not exist."
    exit 1
  fi

#  echo "$file"

  # Get the lowercase version of the file name
  new_name=$(basename "$file" | tr '[:upper:]' '[:lower:]')
#  echo "$new_name"

  # Replace parentheses, brackets, and square brackets with dashes
  new_name=${new_name//[()]/-}
  new_name=${new_name//\[/-}
  new_name=${new_name//\]/-}
#  echo "$new_name"

 # Remove special characters that are not '_', '-', '.' and spaces.
  new_name=${new_name//[^a-zA-Z0-9_. -]/}
#  echo "$new_name"

  # Replace spaces with '_'
  new_name=${new_name//  / }
  new_name=${new_name// /_}
#  echo "$new_name"

  # Replace consecutive occurrences of '_-_', '_-', '-_' and '-_-' by '-'.
  new_name=${new_name//_\-_/-}
  new_name=${new_name//_\-/-}
  new_name=${new_name//-\_/-}
  new_name=${new_name//-\-_/-}
#  echo "$new_name"

  # Replace consecutive occurrences of '-.' by '.'.
  new_name=${new_name//\-\./.}
#  echo "$new_name"

  # Replace consecutive occurrences of '--' with a single '-'.
  new_name=${new_name//--/-}
#  echo "$new_name"

  # Replace multiple underscores with single '_'.
  new_name=${new_name//__/_}
#  echo "$new_name"

  # Remove leading special characters
  new_name=${new_name##[![:alnum:]]}
#  echo "$new_name"

  # Rename the file
  mv "$file" "$(dirname "$file")/$new_name" 2> /dev/null
  echo "$(dirname "$file")/$new_name"
done
