JFHN
====

A better Hacker News reader.

---

JFHN is meant to be a minimal client for Hacker News that focuses on getting out of your way.

Cool things it can do:
- Parse HN pages client-side using Hpple to keep things fast
- Swipe stories to the right to hide them and mark them as uninteresting
- Over time JFHN learns about what you think is interesting and uninteresting and shows this score in the lower right of each story. To do this it uses a naive Bayesian classifier (see jflinter/BayesianKit).

Note that it is still a work-in-progress. Notable things on the to-do list before I ship it:
- Figure out if the interesting/uninteresting classifier is valuable enough to include
- Fix tons of small UI bugs (mostly around the comment UI)
- Better error handling on the rare occasions HN changes its markup (right now generally the app just crashes).
- Better navigation controller management around stories/comments
