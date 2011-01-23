#! /bin/sh

# Run perl modules to create / update list of tournament names
# John Collins 22/1/10

./calibration_update_db.pl 2>>UPDATE_ERRORS

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
exit 0
