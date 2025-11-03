#!/bin/bash

# Colors
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RED="\033[1;31m"
RESET="\033[0m"

# Function: Loading animation
loading() {
  echo -ne "${CYAN}Searching"
  for i in {1..3}; do
    echo -n "."
    sleep 0.3
  done
  echo -e "${RESET}"
}

# Function: Display header
header() {
  clear
  echo -e "${YELLOW}=============================="
  echo -e " Simple Dictionary Tool"
  echo -e "==============================${RESET}"
}

# Function: Search local dictionary
search_local() {
  local word="$1"
  if [ -f "words.txt" ]; then
    local result
    result=$(grep -i "^${word}:" words.txt)
    if [ -n "$result" ]; then
      echo -e "${GREEN}${result}${RESET}"
      return 0
    fi
  fi
  return 1
}

# Function: Search online using dictionaryapi.dev
search_online() {
  local word="$1"

  if ! command -v curl >/dev/null 2>&1; then
    echo -e "${RED}curl not installed. Cannot fetch online meaning.${RESET}"
    return 1
  fi

  loading
  local response
  response=$(curl -s "https://api.dictionaryapi.dev/api/v2/entries/en/${word}")

  if echo "$response" | grep -q '"title": "No Definitions Found"'; then
    echo -e "${RED}No definition found online for '${word}'.${RESET}"
    return 1
  fi

  if command -v jq >/dev/null 2>&1; then
    local meaning pos pronunciation
    meaning=$(echo "$response" | jq -r '.[0].meanings[].definitions[0].definition' | head -n 1)
    pos=$(echo "$response" | jq -r '.[0].meanings[0].partOfSpeech // empty')
    pronunciation=$(echo "$response" | jq -r '.[0].phonetic // empty')

    if [ -n "$meaning" ]; then
      echo -e "${GREEN}${word} (${pos})${RESET}"
      [ -n "$pronunciation" ] && echo -e "${CYAN}Pronunciation:${RESET} ${pronunciation}"
      echo -e "Meaning: ${YELLOW}${meaning}${RESET}"

      # Save to local file if not already saved
      if ! grep -iq "^${word}:" words.txt 2>/dev/null; then
        echo "${word}: ${meaning}" >> words.txt
      fi
      return 0
    fi
  else
    echo -e "${CYAN}Raw response:${RESET}"
    echo "$response" | head -c 200
  fi
  return 1
}

# Function: Add a new word manually
add_word() {
  read -rp "Enter word: " word
  read -rp "Enter meaning: " meaning
  echo "${word}: ${meaning}" >> words.txt
  echo -e "${GREEN}Saved to local dictionary!${RESET}"
}

# Function: View all words
view_words() {
  if [ -f "words.txt" ] && [ -s "words.txt" ]; then
    echo -e "${YELLOW}Your Dictionary:${RESET}"
    cat words.txt
  else
    echo -e "${RED}No words found in local dictionary.${RESET}"
  fi
}

# Function: Delete a word
delete_word() {
  read -rp "Enter the word to delete: " word
  if grep -iq "^${word}:" words.txt; then
    grep -iv "^${word}:" words.txt > temp.txt && mv temp.txt words.txt
    echo -e "${GREEN}'${word}' deleted successfully.${RESET}"
  else
    echo -e "${RED}Word not found in dictionary.${RESET}"
  fi
}

# Function: Search a word (main logic)
search_word() {
  read -rp "Enter a word to search: " WORD
  if [ -z "$WORD" ]; then
    echo -e "${RED}Please enter a valid word.${RESET}"
    return
  fi

  echo ""
  loading

  if search_local "$WORD"; then
    return
  elif search_online "$WORD"; then
    return
  else
    echo -e "${RED}No definition found for '${WORD}'.${RESET}"
    read -rp "➕ Add your own meaning? (y/n): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      read -rp "Enter your meaning: " meaning
      echo "${WORD}: ${meaning}" >> words.txt
      echo -e "${GREEN}Saved to local dictionary!${RESET}"
    fi
  fi
}

# Main Menu Loop
while true; do
  header
  echo "1. Search for a word"
  echo "2. View all saved words"
  echo "3. Add a new word manually"
  echo "4. Delete a word"
  echo "5. Exit"
  echo "------------------------------"
  read -rp "Enter your choice (1-5): " choice

  case $choice in
    1) search_word ;;
    2) view_words ;;
    3) add_word ;;
    4) delete_word ;;
    5) echo -e "${CYAN}Goodbye!${RESET}"; exit 0 ;;
    *) echo -e "${RED}Invalid choice! Try again.${RESET}" ;;
  esac
  echo -e "\nPress Enter to continue..."
  read
done
