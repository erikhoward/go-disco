[![MIT License](https://img.shields.io/github/license/mashape/apistatus.svg)](LICENSE.md)


![alt tag](godisco-logo.png)

# go:disco - Machine Learning using Go

`go:disco` is a Docker container for doing machine learning research and development using Go.

## Quick Start

To start an interactive **go:disco** Docker container:

```sh
docker run --rm -it \
    --name disco \
    erikhoward/go-disco \
    /bin/bash    
```

To run a Jupyter notebook with a Go kernal:
```sh
docker run --rm -it \
    --name disco \
    -p 8888:8888 \
    erikhoward/go-disco \
    jupyter notebook --ip=0.0.0.0 \
    --notebook-dir=${HOME}/notebooks
```

## Contributing

Please see our guide on [contributing to go:disco](CONTRIBUTING.md)

## Bugs and Feature Requests

Found a bug or have a feature request? [Please open a new issue](https://github.com/erikhoward/go-disco/issues/new).

## TODO

- [ ] Add support for opencv
- [ ] Add CUDA support

## Acknowledgements

* [lgo - Go (golang) Jupyter Notebook kernal and interactive REPL](https://github.com/yunabe/lgo)

## License

go:disco is under the MIT license. See the [LICENSE](LICENSE.md) file for details.

## Author
Erik Howard - [https://www.erikhoward.net](https://www.erikhoward.net)
, [@erik_howard](http://twitter.com/erik_howard)