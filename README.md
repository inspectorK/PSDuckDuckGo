## PSDuckDuckGo

Invoke-DuckDuckGoInstantAnswer is a lightweight and simple PowerShell script cmdlet that can be used to request responses from DuckDuckGo's [Instant Answer API](https://duckduckgo.com/api).

![PSDuckDuckGo](images/PSDuckDuckGo.gif)

Download the script and run:

`Get-Help .\Invoke-DuckDuckGoInstantAnswer.ps1 -Full` 

to see full help, usage, and examples.

It is also recommended to use New-Alias to alias `.\Invoke-DuckDuckGoInstantAnswer` to something shorter, i.e. `ddg`.</br></br>
Add the following line to your PowerShell profile to create the alias</br>
`New-Alias ddg <PathToDownloadLocation>\Invoke-DuckDuckGoInstantAnswer.ps1`

## Return Objects

Note that not all fields exposed via the API are captured within the return object.

If the query term results in an "Abstract" type response, a `DDGInstantAnswerAbstractResult` object is returned containing the following data members:

AbstractHeading</br>
AbstractSourceURL</br>
AbstractSource</br>
AbstractImageURL</br>
AbstractText</br>

If the query term results in a "Disambiguation" type response, a `DDGInstantAnswerDisambigResult` object is returned containing the following data members:

DisambigRelatedTopics</br>
DisambigHeading</br>
DisambigSource</br>
DisambigSourceURL</br>
DisambigRelatedTopicsCount</br>

The `-SkipDisambiguation` parameter can be passed to bypass the disambiguation and attempt to return the most related Abstract

Other Instant Answer API return types are not specifically handled and will result in incomplete results.
