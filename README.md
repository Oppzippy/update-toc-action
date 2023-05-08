# update-toc-action

This action updates the interface version of World of Warcraft TOC files. When combined with other actions, this can open a pull request when the interface version changes.

## Inputs

`toc-path` - The path to the TOC file. This input is required. If you want to update multiple toc files, run the action multiple times.  
`product` - The product id to use for the default "## Version: xxx" in the TOC. The default value is "wow" (retail), so if you're not using BigWigs Packager and have "YourAddon_Vanilla.toc", you'll need to set this to "wow_classic_era". Same deal if your primary "YourAddon.toc" is for a WoW version other than retail. Acceptable values are "wow", "wow_classic", and "wow_classic_era".

## Usage

To use this action, add the following to your GitHub workflow file:

```yaml
- name: Update TOC
  uses: oppzippy/update-toc-action@v1
  with:
      toc-path: "path/to/toc/file"
      product: "wow"
```

The action will update the interface version in the TOC file located at path/to/toc/file.
