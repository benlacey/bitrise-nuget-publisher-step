#!/bin/bash

# exit if a command fails
set -e

if [ -z "${nuget_source_path_or_url}" ] ; then
  echo " [!] Missing required input: nuget_source_path_or_url"
  exit 1
fi

if [ -z "${nuget_api_key}" ] ; then
  echo " [!] Missing required input: nuget_api_key"
  exit 1
fi

if [ -z "${nuspec_pattern}" ] ; then
  nuspec_pattern="^\.\/[^/]+.nuspec"
fi

if [ -z "${nuspec_excludepattern}" ] ; then
  nuspec_excludepattern="^$"
fi

if [ -z "${nupkg_pattern}" ] ; then
  nupkg_pattern="^\.\/[^/]+.nupkg"
fi

if [ -z "${nupkg_excludepattern}" ] ; then
  nupkg_excludepattern="^$"
fi

echo "source:    ${nuget_source_path_or_url}"
echo "api key:   ${nuget_api_key}"
echo "nuspecs:   ${nuspec_pattern}"
echo "> exclude: ${nuspec_excludepattern}"
echo "nupkgs:    ${nupkg_pattern}"
echo "> exclude: ${nupkg_excludepattern}"
echo "test mode: ${test_mode}"
echo ""

if [ ! -f "./nuget.exe" ]; then
  echo "Installing latest nuget.exe..."
  curl -O -L https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
fi

nuget="mono ./nuget.exe"

echo " (i) Packaging specs matching pattern ${nuspec_pattern}"

# find nuspecs matching pattern
find -E . -type f -iregex "${nuspec_pattern}" | while read i; do
	if [[ ! ${i} =~ ${nuspec_excludepattern} ]] ; then
		echo " (i) Packaging ${i}..."
		${nuget} pack "${i}" -noninteractive -verbosity "detailed"
		echo " (i) Done"
	fi
done

echo " (i) Package creation finished"



echo " (i) Pushing packages matching pattern ${nupkg_pattern}"

# find packages matching pattern
find -E . -type f -iregex "${nupkg_pattern}" | while read i; do
	if [[ ! ${i} =~ ${nupkg_excludepattern} ]] ; then
		echo " (i) Pushing ${i}..."
		
		if [[ "${test_mode}" == "no" ]] ; then
			echo Executing: ${nuget} push "${i}" -source "${nuget_source_path_or_url}" -apikey ${nuget_api_key} -noninteractive -verbosity "detailed"
			${nuget} push "${i}" -source "${nuget_source_path_or_url}" -apikey ${nuget_api_key} -noninteractive -verbosity "detailed"
		else
			echo TEST MODE: Will execute ${nuget} push "${i}" -source "${nuget_source_path_or_url}" -apikey ${nuget_api_key} -noninteractive -verbosity "detailed"
		fi
		echo " (i) Done"
	fi
done

echo " (i) Package push finished"

exit 0