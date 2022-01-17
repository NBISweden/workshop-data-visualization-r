# workshop-data-visualization-r [![gh-actions-build-status](https://github.com/royfrancis/workshop-template-rmd-ga/workflows/build/badge.svg)](https://github.com/NBISweden/workshop-data-visualization-r/actions?workflow=build)

This repo contains the course material for NBIS workshop **Workshop on Data Visualization in R**. The rendered view of this repo is available [here](https://nbisweden.github.io/workshop-data-visualization-r/).

## Contributing

To add or update contents of this repo (for collaborators), first clone the repo.

```
git clone https://github.com/nbisweden/workshop-data-visualization-r.git
```

Make changes/updates as needed. Add the changed files. Commit it. Then push the repo back.

```
git add .
git commit -m "I did this and that"
git push origin
```

If you are not added as a collaborator, first fork this repo to your account, then clone it locally, make changes, commit, push to your repo, then submit a pull request to this repo.

:exclamation: When updating repo for a new course, change `output_dir: XXXX` in `_site.yml` as the first thing, so that old rendered files are not overwritten.

:exclamation: Do not push any rendered .html files or intermediates.

## Repo organisation

The source material is located on the *main* branch (default). The rendered material is located on the *gh-pages* branch. For most part, one only needs to update content in master. Changes pushed to the *main* branch is automatically rendered to the *gh-pages* branch.

:exclamation: The first build can take around 30-40 mins depending on the number of R packages (listed in **_site.yml**). Subsequent builds take about 2-3 minutes since caching is enabled. Caches are removed after 7 days of last access. A push after that will require a full rebuild.

For more details about repo organisation, updating and modifying this repo, check out the [template repo](https://github.com/royfrancis/workshop-template-rmd-ga).



---

**2022** NBIS • SciLifeLab
