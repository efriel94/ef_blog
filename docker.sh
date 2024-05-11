docker run --name blog --rm --volume=$PWD:/srv/jekyll -p 4000:4000 -it jekyll/jekyll:4.0 jekyll serve
