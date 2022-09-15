#!/bin/sh

dirname=gitlab-backup-$(date "+%Y-%m-%d-%H-%M-%S")
mkdir "$dirname"
cd $dirname

#change these vars:
privateToken=?
userName=?
url=gitlab.com

curl --header "Private-Token: $privateToken" "https://$url/api/v4/users/$userName/projects" | #  \
	jq -r '.[] | .id, .name' |
	while
		IFS= read projectId
		read projectName
	do
		curl --header "Private-Token: $privateToken" "https://$url/api/v4/projects/$projectId/repository/archive.zip" --output $projectName.zip
	done

curl --header "Private-Token: $privateToken" "https://$url/api/v4/groups" |
	jq -r '.[] | .id, .name' |
	while
		IFS= read groupId
		read groupName
	do
		curl --header "Private-Token: $privateToken" "https://$url/api/v4/groups/$groupId/projects" | #  \
			jq -r '.[] | .id, .name' |
			while
				IFS= read projectId
				read projectName
			do
				mkdir -p $groupName
				curl --header "Private-Token: $privateToken" "https://$url/api/v4/projects/$projectId/repository/archive.zip" --output $groupName/$projectName.zip
			done
	done

echo Done! All files downloaded here: $(pwd)
