# GitNoted

GitNoted is a simple document server that works with [Github Wiki](https://help.github.com/articles/about-github-wikis/) or [Gollum](https://github.com/gollum/gollum) to serve foot notes for external web sites just by adding a small script tag.

## JavaScript tag

You can find the JavaScript code on [lib/git_noted/public/js/gitnoted.js](lib/git_noted/public/js/gitnoted.js). This file will be served as `/js/gitnoted.js` from the GitNoted server. You can import it using `<script>` tag as following.

```
<!-- GitNoted depends on jQuery -->
<script src="https://code.jquery.com/jquery-3.1.1.min.js"
    integrity="sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8="
    crossorigin="anonymous"></script>

<!-- GitNoted -->
<link rel="stylesheet" type="text/css" href="http://localhost:4567/css/gitnoted.css" />
<script type="text/javascript" src="http://localhost:4567/js/gitnoted.js"></script>
```

Please replace `http://localhost:4567` to point your GitNoted server (see bellow).

Once the JavaScript tag is set up, you can embed following `<div class="gitnoted" data-labels="label,label,...">` tags your HTML to embed notes. Here is an example:

```
<div class="gitnoted" data-labels="purpose:test,message:hello"></div>
```

`data-labels` is used to search notes by labels. Notes that include all of the labels match.


## Writing documents

Include `:label: label,label,label,...` line to a page. Example:

```
# My first wiki page

Hello!

---

:label: purpose:test,message:hello
```

## Running server with Github Wiki

Prepare following information first:

* Domain names (and ports) of your website that embeds notes. You can use multiple sites. Here uses `example.com` and `localhost:8080` as an example.
* Repository URL of a Github Wiki. Format of URL is `https://github.com/<user>/<repo>.wiki.git` where "&lt;user&&gt;" and &lt;repo&gt; are your repository's username and repository name.

This command starts a server on http://0.0.0.0:4567.

```
$ gem install gitnoted
$ gitnoted "https://github.com/frsyuki/gitnoted.wiki.git" \
           ./repo \
           -a example.com -a localhost:8080 \
           -h 0.0.0.0 -p 4567
```

## Running server with a private github repository

Instead of using public Github Wiki (Github Wiki is always public), you can put Markdown files on a private github repository. File name must be `<name>.md` (ends with `.md`).

To start GitNoted for a private github repository, prepare following information:

* Domain names (and ports) of your website that embeds foot notes. You can use multiple sites. Here uses `example.com` and `localhost:8080` as an example.
* Repository URL of the Github repository. Format of URL is `https://github.com/<user>/<repo>.git` where "&lt;user&&gt;" and &lt;repo&gt; are your repository's username and repository name.
* [Github personal API token](https://github.com/blog/1509-personal-api-tokens): This token is used to pull a private Github. You can create a token on [your account configuration page](https://github.com/settings/tokens). You need to set it to `GITHUB_ACCESS_TOKEN` environment variable.

This command starts a server on http://0.0.0.0:4567.

```
$ gem install gitnoted
$ export GITHUB_ACCESS_TOKEN=abcdef0123456789abcdef0123456789abcdef01
$ gitnoted \
           "https://github.com/frsyuki/my_secret_repository.wiki.git" \
           ./repo \
           -a example.com -a localhost:8080 \
           -h 0.0.0.0 -p 4567
```

## Deploying to Heroku

You need to create 4 files on a new git repository

### Procfile

Put a gitnoted command in your `Procfile` with `$PORT` variable as the port number. Here is an example:

```
web: bundle exec gitnoted "https://github.com/frsyuki/gitnoted.wiki.git ./repo -a example.com -h 0.0.0.0 -p $PORT
```

### Gemfile

```
source "https://rubygems.org"
ruby "2.4.0"
gem "gitnoted"
```

### .buildpacks

```
# .buildpacks
https://github.com/ddollar/heroku-buildpack-apts
https://github.com/heroku/heroku-buildpack-ruby
```

### Aptfile

```
# Aptfile
cmake
pkg-config
```

## Server usage

```
$ gitnoted [options] <git url> <local path to store>
  options:
    -a, --allow-origin DOMAIN[:PORT] Allow cross-origin resource sharing (CORS) from this domain (can be set multiple times)
    -h, --host ADDRESS               Bind address (default: 'localhost')
    -p, --port PORT                  Port (default: 4567)
    -e, --extra-app PATH.rb          Add an extra Sinatra application
    -i, --interval SECONDS           Interval to update the git repository
        --threads MIN:MAX            Number of HTTP worker threads
  environment variables:
    GIT_USERNAME                 Git username
    GIT_PASSWORD                 Git password
    GITHUB_ACCESS_TOKEN          Github personal API token
```

----

    GitNoted
    Author: Sadayuki Furuhashi
    License: MIT

