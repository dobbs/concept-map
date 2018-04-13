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
