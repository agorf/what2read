# what2read

Given the shortage of time and the abundance of great books, it makes sense to
read books in order of importance. what2read helps you answer a very specific
question: "Which book should I read next?"

It consists of three scripts:

### `generate-oauth-access-token`

Facilitates in creating the necessary OAuth access tokens for the [Goodreads
API][API]. It is run once (see _Configuration_ for more info).

### `import-books`

Accesses your bookshelves on [Goodreads][] and imports books into an SQLite
database. It also downloads book covers from [Goodreads][], OpenLibrary and
Google (fallbacks). When run more than once, it re-imports books but skips
covers that have already been downloaded.

### `serve`

Sets up an HTTP server and opens the target URL in a browser with books rendered
in sortable columns: title, authors, ISBN, pages, score, rating, ratings,
shelves.

_score_ is an additional [calculated][score] column that takes into account both
a book's average rating and number of ratings, giving a more accurate estimate
of its standing.

## Installation

Clone the repo:

    $ git clone https://github.com/agorf/what2read.git

Enter the directory:

    $ cd what2read

And install the necessary Gems using [Bundler](http://bundler.io/):

    $ bundle install

## Configuration

You need to do this only once.

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

    $ bundle exec ruby bin/generate-oauth-access-token
    Opening http://www.goodreads.com/oauth/authorize?oauth_token=...

    Press ENTER after you have authorized the app

This will print a Goodreads URL (as well as opening it with your browser) from
which you can authorize the script. Once done, return to the terminal and press
the Enter key:

    Place the following into your .env file:

    OAUTH_ACCESS_TOKEN=...
    OAUTH_ACCESS_SECRET=...

Copy the last two lines and place them in the `.env` file, replacing the
existing ones that are empty.

You are now ready to use the script.

## Usage

Import or re-import books:

    $ bundle exec ruby -I lib bin/import-books

View them:

    $ bundle exec ruby -I lib bin/serve

## License

[MIT][]

## Author

Angelos Orfanakos, https://agorf.gr/

[Goodreads]: https://www.goodreads.com/
[API]: https://www.goodreads.com/api
[score]: http://stackoverflow.com/a/2134629
[key]: https://www.goodreads.com/api/keys
[MIT]: https://github.com/agorf/what2read/blob/master/LICENSE.txt
