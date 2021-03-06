[![Build Status](https://travis-ci.org/pcboy/dailycrap.svg?branch=master)](https://travis-ci.org/pcboy/dailycrap)

# Dailycrap

Welcome to Dailycrap, the solution to micro management!  
Your company is using scrum and force you to do that daily meeting?  
Dailycrap is here to generate that daily meeting for you.  
Because engineers use automated tools when they can.  

Note: This has been done in a few hours and may have some bugs, feel free to report those.  
Expect a lot of breaking changes, it's alpha.

## Installation
```
gem install dailycrap
```

## Usage
Dailycrap assumes your in progress PRs/issues have the label "in progress"  
It also assumes you are not working on weekends, so Yesterday becomes Friday when you run the script on Monday.  
You can always use --day '2017-01-01' to specify a specific date (supports formats supported by Date.parse in ruby)  
Nothing else should matter  
You need a file containing only your github token see https://github.com/settings/tokens  

```
$> dailycrap -h
	Dailycrap is here to generate your daily meeting.
	-t, --token-file=<s>      File containing your github token (https://github.com/settings/tokens)
	-r, --repository=<s>      The repository you are working on
	-o, --organization=<s>    Your organization name
	-d, --day=<s>             Day you want to generate a report for (default is yesterday or last friday if monday)
	-e, --edit                send generated report to your $EDITOR
	-h, --help                Show this message

$> dailycrap --token-file=.github_token --organization your_github_orgname --repository your_repo --edit

Yesterday
  Worked on:
    Connect to #1204 Do this wonderful stuff
    [CLOSED :tada:] Test PR, ignore

  Reviewed:
    PR 42, killing Scrum
    

Today:
  In progress:
    Connect to #123124 Wonderful feature
```

## License
dailycrap is under the WTFPL. Do whatever you want.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pcboy/dailycrap. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

