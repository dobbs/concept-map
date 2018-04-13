# concept-map

an in-browser tool for sketching [Concept Maps](http://en.wikipedia.org/wiki/Concept_map)

# development

Once:
``` bash
docker-compose run --rm node bash
npm install
[ -x phantomjs ] || curl -sSL \
  https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 | \
  tar -jv --strip-components=2 --wildcards --extract '*/bin/phantomjs'
```

Run tests:
``` bash
docker-compose run --rm node bash
[ -e /usr/local/bin/phantomjs ] || \
  ln -s phantomjs /usr/local/bin/
lineman spec-ci
```

Run dev server & UI:
``` bash
docker-compose up -d web
open localhost:8000
```

# usage

In the browser, type `alt` twice to start the editor controls.

Just type to begin creating a node.  `return` saves the node to the graph.

To create links:
1. use `arrow` keys to choose a node.
2. `esc` cancels the link (true through step 7 below).
3. `return` selects the chosen node as the source for the link.
4. use `arrow` keys to choose another node.
5. `return` selects the chosen node as the target.
6. type to begin labeling the link.
7. `return` to save the link.

All links must be labeled.  Circular links (when a node links to itself) are allowed.  Labels can also be the source or target of other links.
