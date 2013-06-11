Kahn Project
===================

This project is named after Robert Elliot "Bob" Kahn, who, along with Vint Cerf, invented the TCP/IP.

This project provides restful API for my crawled data, currently it providing the following services:

Company directory
------------------

Company directory is useful when I want to write internal apps which need to provide identity to my
colleagues. So a crawler will crawl the company directory data every week and put the crawled info
into a mongodb database, for this api to consume.

GNATS
------

GNATS is a bug tracking system which is slow and primitive. I'd like to use/query it fast and elegant.
So a crawler will crawl the gnats server for the PRs of designated names every 4 hours and put the data
into a mongodb database, for this api to consume.