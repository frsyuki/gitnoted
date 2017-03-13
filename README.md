# GitNoted

GitNoted is a simple document server that works with [Github Wiki](https://help.github.com/articles/about-github-wikis/) or [Gollum](https://github.com/gollum/gollum) to serve foot notes for external web sites just by adding a small script tag.

* [JavaScript tag](#javascript-tag)
* [Writing notes](#writing-notes)
* [Running server with Github Wiki](#running-server-with-github-wiki)
* [Running server with other git repositories](#running-server-with-other-git-repositories)
* [Deploying to Heroku](#deploying-to-heroku)
* [Server usage](#server-usage)

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

Once the JavaScript tag is set up, you can add following `<div class="gitnoted" data-labels="label,label,...">` tags your HTML to embed notes. Here is an example:

```
<div class="gitnoted" data-labels="purpose:test,message:hello"></div>
```

`data-labels` is used to search notes by labels. Notes that include all of them match.


## Writing notes

Edit mode must be Markdown. Other formats are not supported.

In the body of a page, you need to include `:label: label,label,label,...` line at the beginning or at the end. Example:

```
# My first wiki page

Hello!

---

:label: purpose:test,message:hello
```

## Running server with Github Wiki

Prepare following information first:

* Domain names (and ports) of your website that embeds notes. You can have multiple web sites. Here uses `example.com` and `localhost:8080` as an example.
* Repository URL of a Github Wiki. Format of the URL is `https://github.com/<user>/<repo>.wiki.git` where "&lt;user&gt; and &lt;repo&gt; are your repository's username and repository name.

This command starts a server on http://localhost:4567:

```
$ gem install gitnoted
$ gitnoted "https://github.com/frsyuki/gitnoted.wiki.git" \
           ./repo \
           -a example.com -a localhost:8080 \
           -h localhost -p 4567
```

If your repository is private, you also need to set `GITHUB_ACCESS_TOKEN` environment variable. You can create a token on [your account configuration page](https://github.com/settings/tokens). Example:

```
$ gem install gitnoted
$ export GITHUB_ACCESS_TOKEN=abcdef0123456789abcdef0123456789abcdef01
$ gitnoted \
           "https://github.com/frsyuki/my_secret_repository.wiki.git" \
           ./repo \
           -a example.com -a localhost:8080 \
           -h localhost -p 4567
```

## Running server with other git repositories

Instead of using Github Wiki, you can use any git repositories that contain files named `<name>.md`. You can use your text editor or tools such as [Gollum](https://github.com/gollum/gollum) to push `.md` files.

To start GitNoted for those git repositories, prepare following information:

* Domain names (and ports) of your website that embeds notes. You can have multiple web sites. Here uses `example.com` and `localhost:8080` as an example.
* Repository URL of the git repository. It should provide http access (ssh is not supported at this moment).
* Username and password of the git repository. You need to set them to GIT_USERNAME and GIT_PASSWORD environment variables.

This command starts a server on http://localhost:4567:

```
$ gem install gitnoted
$ export GIT_USERNAME=myname
$ export GIT_PASSWORD=topsecret
$ gitnoted \
           "https://github.com/frsyuki/my_secret_repository.wiki.git" \
           ./repo \
           -a example.com -a localhost:8080 \
           -h localhost -p 4567
```

## Deploying to Heroku

You can create a new Heroku application using this command:

```
$ gem install heroku
$ heroku create --buildpack https://github.com/heroku/heroku-buildpack-multi.git
```

Or, you can use your existent Heroku application:

```
$ heroku create buildpacks:set https://github.com/heroku/heroku-buildpack-multi.git --app=your_app_name
```

Then, you need to put 4 files to the application.

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
https://github.com/ddollar/heroku-buildpack-apts
https://github.com/heroku/heroku-buildpack-ruby
```

### Aptfile

```
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

