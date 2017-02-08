# wbsirn

Given the shortness of free time in modern life and the abundance of great books
nowadays, it makes sense to read books in order of importance.

wbsirn is a simple Ruby script that helps you answer a very specific question:
"**W**hich **b**ook **s**hould **I** **r**ead **n**ext?"

wbsirn accesses your "to-read" [Goodreads][] bookshelf using their [API][] and
prints a listing of its books, ordered by [a score][] that takes into account
both the average rating of the book and the number of ratings it has received.

[Goodreads]: https://www.goodreads.com/
[API]: https://www.goodreads.com/api
[a score]: http://stackoverflow.com/a/2134629
