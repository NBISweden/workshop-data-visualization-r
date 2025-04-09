# workshop-data-visualization-r [![gh-actions-build-status](https://github.com/NBISweden/workshop-data-visualization-r/actions/workflows/docker.yml/badge.svg)](https://github.com/NBISweden/workshop-data-visualization-r/actions/workflows/docker.yml)

This repo contains the course material for NBIS workshop **Advanced Data Visualization**. The rendered view of this repo is available [here](https://nbisweden.github.io/workshop-data-visualization-r/).

## Contributing

To add or update contents of this repo (for collaborators), first clone the repo.

```
git clone --depth 1 --single-branch --branch main https://github.com/nbisweden/workshop-data-visualization-r.git
```
Then navigate to the repo directory and create new branch.

```
cd workshop-data-visualization-r
git checkout -b my-branch
```

Make changes/updates as needed. Add the changed files. Commit it. Then push the repo back.

```
git add .
git commit -m "I did this and that"
git push origin my-branch
```

Then create a pull request to the main branch of this repo. You can do this from the GitHub website.

If you are not a collaborator, you can still contribute by creating a pull request. You can do this by forking the repo to your account, making changes, and then creating a pull request from your forked repo to this repo.


:exclamation: When updating repo for a new course, change `output-dir: XXXX` in `_quarto.yml` 
as the first thing, so that old rendered files are not overwritten.

:exclamation: Do not push any rendered .html files or intermediates.

## Docker
### Local build/preview using Docker

You can preview changes and build the whole website locally without a local installation of R or dependency packages by using the pre-built Docker image.

Clone the repo if not already done. Make sure you are standing in the repo directory.

To build the complete site,

```
docker run --platform linux/amd64 --rm -u 1000:1000 -v ${PWD}:/qmd ghcr.io/nbisweden/workshop-adv-data-viz:latest
```

To build a single file (for example `index.qmd`),

```
docker run --platform linux/amd64 --rm -u 1000:1000 -v ${PWD}:/qmd ghcr.io/nbisweden/workshop-adv-data-viz:latest quarto render index.qmd
```

:exclamation: Output files are for local preview only. Do not push any rendered .html files or intermediates.

### Convert HTML slides to PDF

```
docker run --platform=linux/amd64 -v $PWD:/work astefanutti/decktape https://nbisweden.github.io/workshop-data-visualization-r/2505/topics/ggplot/slide_gg1.html /work/slide_ggplot_intro.pdf
```

### Serving and automatic rendering

You can use `quarto preview` to serve the site, and handle automatic rebuilding of pages when any `.qmd` file is changed.

```bash
# serve the site
docker run --rm -it --platform linux/amd64 -u $(id -u):$(id -g) -v ${PWD}:/qmd -p 8800:8800  ghcr.io/nbisweden/workshop-adv-data-viz:latest quarto preview --port 8800 --host 0.0.0.0
```

Go to [http://localhost:8800/](http://localhost:8800/) or [http://0.0.0.0:8800](http://0.0.0.0:8800) in your browser.

### Building your own docker container

```bash
# build container
docker build --platform linux/amd64 -t ghcr.io/nbisweden/workshop-adv-data-viz:latest .

# push to ghcr
# docker login ghcr.io
docker push ghcr.io/nbisweden/workshop-adv-data-viz:latest

# run container in the root of the repo
docker run --rm --platform linux/amd64 -u $(id -u):$(id -g) -v ${PWD}:/qmd ghcr.io/nbisweden/workshop-adv-data-viz:latest
docker run --rm --platform linux/amd64 -u $(id -u):$(id -g) -v ${PWD}:/qmd ghcr.io/nbisweden/workshop-adv-data-viz:latest quarto render index.qmd
```

## Repo organisation

The source material is located on the *main* branch (default). The rendered material is located on the *gh-pages* branch. One only needs to update source materials in *main*. Changes pushed to the *main* branch is automatically rendered to the *gh-pages* branch using github actions.

:exclamation: Every push rebuilds the whole website using a pre-built docker image.

This repo is loosely based on the quarto template [specky](https://github.com/royfrancis/specky).

---

**2025** • NBIS • SciLifeLab
