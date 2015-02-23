# Neopoly Open Source

Generates a list of all neopoly Open Source projects.

## Usage

    $ rake

## Configuration

You may use your own GitHub API access token to prevent a
`Octokit::TooManyRequests` exception as GitHub has hard rate limits per IP.

1. Create a new token using your [GitHub application settings](https://github.com/settings/applications#personal-access-tokens) using the default scopes.
2. Create a new file called `.access_tokens.yml` using the following
format:

```yml
    github: YOUR_ACCESS_TOKEN
```

### Generate projects page

    $ rake projects
    $ git commit

### Generate project list

    # Might take a long time - be patient
    $ rake projects:list
    $ git commit
