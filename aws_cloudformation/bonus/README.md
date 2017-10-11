# Visualizing CloudFormation templates

My team uses a lot of CloudFormation templates.

This tools helps visualize the stack created by a CloudFormation template.

### Prerequisites

* Graphviz
* ImageMagick
* Python 2.7
* Linux or OSX (sorry Windows users.  It might work under cygwin but I've never tested it with cygwin)

### Deployment

Just run setup to create the necessary symlinks to the files.

Run the following shell command:
```
./setup.sh
```

### Usage

Minimal error handling is done.  The script just expects the CFN template as the parameter.

Run the following shell command:
```
cfn-visualize template_filename
```
where the `template_filename` is the actual CloudFormation template.


## Built With

* [vi](https://en.wikipedia.org/wiki/Vi) - The editor I used for creating the scripts
* [Graphviz](http://www.graphviz.org/) - Software than takes care of the rendering
* [ImageMagick](https://www.imagemagick.org/) - Converts the SVG to PNG
