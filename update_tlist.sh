#! /bin/sh

# Run perl modules to create / update list of tournament names
# John Collins 22/1/10

./tournament_update_db.pl 2>>UPDATE_ERRORS

exit_code=$?

# If no changes the update program gives an exit code of zero
 
if [ $exit_code -eq 0 ]
then
	exit 0
fi

# If there are changes it gives a code of 1 anything else it gives some other code.

if [ $exit_code -ne 1 ]
then
	(date; echo "Aborting $0") >>UPDATE_ERRORS
	exit 10
fi

./tournament_list_gen.pl 2>>UPDATE_ERRORS

if [ $? -ne 0 ]
then
	(date; echo "$0: List gen failed") >>UPDATE_ERRORS
	exit 11
fi

	