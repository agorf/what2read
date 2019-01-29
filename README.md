# what2read

Given the shortage of time and the abundance of great books, it makes sense to
read books in order of importance. what2read helps you answer a very specific
question: "Which book should I read next?"

This is how it looks like:

![screenshot](https://raw.githubusercontent.com/agorf/what2read/master/screenshot.png)

It consists of three scripts:

### `bin/generate-oauth-access-token`

Facilitates in creating the necessary OAuth access tokens for the [Goodreads
API][API]. It is run once (see _Configuration_ for more info).

### `bin/import-books`

Accesses your bookshelves on [Goodreads][] and imports books into an SQLite
database. It also downloads book covers from [Goodreads][], OpenLibrary and
Google (fallbacks). When run more than once, it re-imports books but skips
covers that have already been downloaded.

### `config.ru`

Sets up an HTTP server listing books in sortable columns: title, authors, ISBN, pages, score, rating, ratings,
shelves.

_score_ is an additional [calculated][score] column that takes into account both
a book's average rating and number of ratings, giving a more accurate estimate
of its standing.

## Installation

Clone the repo:

    $ git clone https://github.com/agorf/what2read.git
    $ cd what2read

With [Docker][], you don't need Ruby, Bundler, Gems etc. Just build the image:

    $ docker-compose build what2read

If you don't have [Docker][], install the necessary Gems with [Bundler][]:

    $ bundle install

## Configuration

You need to do the following only once.

### Step 1: Create an environment file

    $ cp .env.sample .env
    $ chmod go-r .env # so that other users cannot read it

### Step 2: Create a Goodreads API key

Visit Goodreads and apply for a [developer API key][key]. Copy the key and the
secret and set them as `GOODREADS_API_KEY` and `GOODREADS_API_SECRET` in the
`.env` file respectively.

### Step 3: Set your Goodreads user ID

Visit [Goodreads][] and go to your profile page. Copy your numeric user ID from
the URL and set it as `GOODREADS_USER_ID` in the `.env` file.

### Step 4: Create an OAuth access token

With [Docker][]:

    $ docker-compose run --rm what2read ./bin/generate-oauth-access-token

Without [Docker][]:

    $ bundle exec ruby bin/generate-oauth-access-token

Follow the printed instructions:

    Open https://www.goodreads.com/oauth/authorize?oauth_token=... in a browser

    Press ENTER after you have authorized the app

    Place the following into your `.env` file:

    OAUTH_ACCESS_TOKEN=...
    OAUTH_ACCESS_SECRET=...

Copy the last two lines and place them in the `.env` file, replacing the
existing ones that are empty.

You are now ready to use the script.

## Usage

Import or re-import books with [Docker][]:

    $ docker-compose run --rm what2read ./bin/import-books

Without [Docker][]:

    $ bundle exec ruby -I lib bin/import-books

Run the server with [Docker][]:

    $ docker-compose up what2read

Without [Docker][]:

    $ bundle exec rackup -I lib

Press `Ctrl-C` to stop the server.

View the books:

    $ xdg-open http://localhost:9292/

## License

[MIT][]

## Author

Angelos Orfanakos, https://agorf.gr/

[Goodreads]: https://www.goodreads.com/
[API]: https://www.goodreads.com/api
[score]: http://stackoverflow.com/a/2134629
[key]: https://www.goodreads.com/api/keys
[MIT]: https://github.com/agorf/what2read/blob/master/LICENSE.txt
[Bundler]: http://bundler.io/
[Docker]: https://www.docker.com/
