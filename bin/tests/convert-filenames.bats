#!/usr/bin/env bats

@test "Test if file exists" {
  run convert-filenames.sh non_existent_file.txt

  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "File 'non_existent_file.txt' does not exist." ]
}

@test "Test already correct file name conversion" {
  og_file='/tmp/already_correct-filename.test'
  new_name="$og_file"

  touch "$og_file"

  run convert-filenames.sh "$og_file"

  # Verify the file stayed the same
  [ "$status" -eq 0 ]
  [ "$output" = "$new_name" ]

  rm "$new_name"
}

@test "Test file name conversion with brackets and spaces" {
  og_file='/tmp/file.name-with(brackets]and spaces.test'
  new_name='/tmp/file.name-with-brackets-and_spaces.test'

  touch "$og_file"

  run convert-filenames.sh "$og_file"

  # Verify the file has been renamed correctly
  [ "$status" -eq 0 ]
  [ "$output" = "$new_name" ]

  rm "$new_name"
}
###
@test "Test file name conversion with consecutive occurrences of characters" {
  og_file='/tmp/filename_-_with--consecutive__occurrences-.test'
  new_name='/tmp/filename-with-consecutive_occurrences.test'

  touch "$og_file"

  run convert-filenames.sh "$og_file"

  # Verify the file has been renamed correctly
  [ "$status" -eq 0 ]
  [ "$output" = "$new_name" ]

  rm "$new_name"
}

@test "Test file name conversion with leading special characters and uppercases" {
  og_file='/tmp/@FileName-w-leaDing-char-aNd-Uppercases'
  new_name='/tmp/filename-w-leading-char-and-uppercases'

  touch "$og_file"

  run convert-filenames.sh "$og_file"

  # Verify the file has been renamed correctly
  [ "$status" -eq 0 ]
  [ "$output" = "$new_name" ]

  rm "$new_name"
}
