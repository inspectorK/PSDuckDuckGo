<#
.SYNOPSIS
Invokes the DuckDuckGo Instant Answer API

.DESCRIPTION
Invokes a GET rest method to get instant answer results for a given query.  For quicker usage, use "New-Alias" to set an alias to "ddg"

.PARAMETER Query
The search term to query

.PARAMETER NoRedirect
Skip HTTP redirects (for !bang commands)

.PARAMETER NoHTML
Remove HTML from text, e.g. bold and italics

.PARAMETER SkipDisambiguation
Skip disambiguation (D) Type responses

.EXAMPLE
.\Invoke-DDGInstantAnswer.ps1 -Query "Brood War"
This example invokes the DuckDuckGo instant answer api for the search term "Brood War"

.EXAMPLE 
.\Invoke-DDGInstantAnswer.ps1 -Query "Star Wars" -SkipDisambiguation
This example invokes the DuckDuckGo instant answer api for the search term "Star Wars".  This returns a "D" type so to force the return use -SkipDisambiguation

.LINK
https://duckduckgo.com
https://api.duckduckgo.com/api

#>

[CmdletBinding()]
param(
    [Alias('q')]
    [Parameter(Mandatory=$true,Position=0)]
    [string]
    $Query,

    [Alias('nr')]
    [Parameter(Mandatory=$false,Position=1)]
    [switch]
    $NoRedirect,

    [Alias('nh')]
    [Parameter(Mandatory=$false,Position=2)]
    [switch]
    $NoHTML,

    [Alias('sd')]
    [Parameter(Mandatory=$false,Position=3)]
    [switch]
    $SkipDisambiguation
)

# Declare Script Globals and Classes for return objects
$DDGAPI_URIRoot = 'https://api.duckduckgo.com'

class DDGInstantAnswerAbstractResult
{
    [String]$AbstractHeading
    [String]$AbstractSourceURL
    [String]$AbstractSource
    [String]$AbstractImageURL
    [String]$AbstractText
}
class DDGInstantAnswerDisambigResult
{
    [String]$DisambigHeading
    [String]$DisambigSource
    [String]$DisambigSourceURL
    [Int]$DisambigRelatedTopicsCount
    [System.Collections.Hashtable]$DisambigRelatedTopics = @{}
}

# ----------------------------------------------------------------
# Main
# ----------------------------------------------------------------

if ([String]::IsNullOrWhiteSpace($Query))
{
    Write-Error "Query must not be null or whitespace."
    exit
}

$DDGAPI_URIBody = @{
    q = $Query
    format = "json"
    no_redirect = "0"
    no_html = "0"
    skip_disambig="0"
}

# Handle other params
if ($NoRedirect)
{
    $DDGAPI_URIBody.no_redirect = "1"
}
if ($NoHTML)
{
    $DDGAPI_URIBody.no_html = "1"
}
if ($SkipDisambiguation)
{
    $DDGAPI_URIBody.skip_disambig = "1"
}

# Let API do it's job
$Result = Invoke-RestMethod -Method Get -Uri $DDGAPI_URIRoot -Body $DDGAPI_URIBody -ErrorAction Stop

if ($Result.Type -eq "D" -and !$SkipDisambiguation)
{
    # This is a disambig type and we were not told to skip
    # Construct Result Object
    $DDGInstantAnswer = [DDGInstantAnswerDisambigResult]::new()
    $DDGInstantAnswer.DisambigHeading = $Result.Heading
    $DDGInstantAnswer.DisambigSource = $Result.AbstractSource
    $DDGInstantAnswer.DisambigSourceURL = $Result.AbstractURL
    foreach ($RelatedTopic in $Result.RelatedTopics)
    {
        $DDGInstantAnswer.DisambigRelatedTopicsCount++
        $Text = $RelatedTopic.Text
        $TextURL = ($RelatedTopic.Result -split "`"")[1]  # TODO This is super janky, fixup later

        # SilentlyContinue so the Add() doesn't throw - related to TODO below
        $ErrorActionPreference = "SilentlyContinue" 

        $DDGInstantAnswer.DisambigRelatedTopics.Add($Text,$TextURL) 
        # TODO some disambig topics also contain "Other uses" and "see also" results, need to handle these as well
        $ErrorActionPreference = "Continue"
    }
}

else
{
    # We either didn't get "D" type result, or were told to skip
    # Construct Result Object
    $DDGInstantAnswer = [DDGInstantAnswerAbstractResult]::new()
    $DDGInstantAnswer.AbstractHeading = $Result.Heading
    $DDGInstantAnswer.AbstractSourceURL = $Result.AbstractURL
    $DDGInstantAnswer.AbstractSource = $Result.AbstractSource
    $DDGInstantAnswer.AbstractImageURL = $Result.Image
    $DDGInstantAnswer.AbstractText = $Result.AbstractText
}

<#
# If we didn't skip, but got a Disambiguation result, try again and skip Disambiguation this time
if (!$SkipDisambiguation -and $Result.Type -eq "D")
{
    $DDGAPI_URIBody.skip_disambig = "1"
    $Result = Invoke-RestMethod -Method Get -Uri $DDGAPI_URIRoot -Body $DDGAPI_URIBody -ErrorAction Stop
}


#>

return $DDGInstantAnswer