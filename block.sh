#!/bin/bash

# list all sites to be blocked. 
# primary domain and sub-domains are accepted. 
BLOCKED_SITES="facebook.com
plus.google.com
instagram.com
reddit.com
twitter.com
tumblr.com
flickr.com
vine.com
meetup.com
linkedin.com"

# handle www subdomain and ipv6
# may insert unnecessory entries, if subdomains are defined, but no harm done. 
#   e.g. for plus.google.com -> www.plus.google.com 
BSITESARR=()
while read -r line; do
   BSITESARR+=( "127.0.0.1    $line" )
   BSITESARR+=( "127.0.0.1    www.$line" )
   BSITESARR+=( "::    $line" )
   BSITESARR+=( "::    www.$line" )
done <<< "$BLOCKED_SITES"

BSITES=$(printf "\n%s" "${BSITESARR[@]}")       # join array elements with new line character 
BSITES=${BSITES:1}   				# removing the extra new line character added

sudo awk -v BSITES="$BSITES" '
    $0 == "# END DYNAMIC BLOCK - DO NOT EDIT MANUALLY" {skip=0; print BSITES; substituted=1}
    !skip {print}
    $0 == "# BEGIN DYNAMIC BLOCK - DO NOT EDIT MANUALLY" {skip=1}
    END {
         if (!substituted) {
            print "";
            print "# BEGIN DYNAMIC BLOCK - DO NOT EDIT MANUALLY";
            print BSITES;
            print "# END DYNAMIC BLOCK - DO NOT EDIT MANUALLY";
        }
    }
' /etc/hosts > /tmp/hosts.tmp

sudo cp /tmp/hosts.tmp /etc/hosts
sudo rm /tmp/hosts.tmp
