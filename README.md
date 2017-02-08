# what2read

Given the shortness of free time and the abundance of great books nowadays, it
makes sense to read books in order of importance.

what2read is a simple Ruby script that helps you answer a very specific
question: "Which book should I read next?"

It does that by accessing your [Goodreads][] "to-read" bookshelf, printing a
listing of its books ordered by [a score][] which takes into account both the
average rating of the book and the number of ratings it has received.

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

    $ bundle exec ruby what2read.rb
    ...
     10 4.42     340 4.34 The Principles of Object-Oriented JavaScript...... http://www.goodreads.com/book/show/20799234
      9 4.35    7044 4.35 Clean Code: A Handbook of Agile Software Craftsman http://www.goodreads.com/book/show/3735293
      8 4.35   41693 4.35 Sapiens: A Brief History of Humankind............. http://www.goodreads.com/book/show/23692271
      7 4.35   74405 4.35 Cosmos............................................ http://www.goodreads.com/book/show/55030
      6 4.36    3465 4.35 Code: The Hidden Language of Computer Hardware and http://www.goodreads.com/book/show/44882
      5 4.37    2152 4.36 Tools of Titans: The Tactics, Routines, and Habits http://www.goodreads.com/book/show/31823677
      4 4.47     369 4.38 The Elements of Computing Systems: Building a Mode http://www.goodreads.com/book/show/910789
      3 4.48     602 4.42 Practical Vim: Edit Text at the Speed of Thought.. http://www.goodreads.com/book/show/13607232
      2 4.45    3051 4.44 Structure and Interpretation of Computer Programs. http://www.goodreads.com/book/show/43713
      1 4.56    1491 4.53 Practical Object Oriented Design in Ruby.......... http://www.goodreads.com/book/show/13507787

The columns are in order: rank (descending), average rating on Goodreads, number
of ratings on Goodreads, calculated score (descending), title, URL

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
