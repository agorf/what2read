# what2read

Given the shortness of free time and the abundance of great books nowadays, it
makes sense to read books in order of importance.

what2read is a simple Ruby script that helps you answer a very specific
question: "Which book should I read next?"

It does that by accessing your [Goodreads][] "to-read" bookshelf, printing an
HTML listing of its books ordered by [a score][] which takes into account both
the average rating of the book and the number of ratings it has received.

## Configuration

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

    $ bundle install # to install necessary Gems
    $ bundle exec ruby w2r_generate_oauth_access_token.rb
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

    $ bundle exec ruby what2read.rb >out.html
    $ xdg-open out.html

Make sure you run the script regularly since books are continually rated on
Goodreads and the ranking is pretty volatile.

## License

Licensed under the [MIT license][].

## Author

Angelos Orfanakos, http://agorf.gr/

[Goodreads]: https://www.goodreads.com/
[API]: https://www.goodreads.com/api
[a score]: http://stackoverflow.com/a/2134629
[key]: https://www.goodreads.com/api/keys
[MIT license]: https://github.com/agorf/what2read/blob/master/LICENSE.txt
