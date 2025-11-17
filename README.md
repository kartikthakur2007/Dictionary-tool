Simple Dictionary Tool (Bash Script)

A lightweight command-line dictionary tool written entirely in Bash.

It supports:

1.Local dictionary search

2.Online dictionary lookup using dictionaryapi.dev

3.Adding new words manually

4.Deleting saved words

5.Persistent storage using words.txt

6.Styled terminal output with colors

7.Loading animation for better user experience****

Features
1. Local Search

Searches for a word in the locally saved dictionary file (words.txt).

2. Online Search

If a word is not found locally, the script fetches the definition from the online API:

https://api.dictionaryapi.dev/api/v2/entries/en/<word>

3. Automatic Saving

If the script retrieves an online definition, it automatically saves it to the local dictionary for future offline use.

4. Add Words Manually

Users can manually add words and custom meanings.

5. Delete Words

Allows deletion of existing entries from the dictionary.

6. Colorful and Clean User Interface

The script uses ANSI color codes to provide a more readable interface.
