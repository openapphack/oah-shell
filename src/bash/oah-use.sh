#!/bin/bash
# oah use is to switch between the environments
function __oah_use()
{
       if [[ -z $1 ]]
       then
				 echo "Error :Please provide the environment name from oah env list"
				 ove help
			 else
        environment_name=$1
        if [[ "$environment_name" = "$(oah list | grep $environment_name | cut -d " " -f 1 | sed 's/>//')" ]]
        then
          CURRENT_ENV=`oah show current | cut -d " " -f 5`
          if [[ "$environment_name" = "$CURRENT_ENV" ]]
          then
            echo "$environment_name is already installed , please select another environment"
          else
        oah remove
        oah install -s $environment_name
      fi
else
        echo "Error : Please provide correct environment name  from oah env list"
fi
fi
}
