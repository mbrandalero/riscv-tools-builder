.PHONY: help
help:
	@echo '                                                                          '
	@echo 'Makefile for riscv doc                                                    '
	@echo '                                                                          '
	@echo 'Usage:                                                                    '
	@echo '   make help                           show help                          '
	@echo '                                                                          '
	@echo '   make git-clone                     clone source                        '
	@echo '   make builder                       builder image                       '
	@echo '   make tool-chain                    tool chain image                    '
	@echo '                                                                          '
	@echo '                                                                          '


BUILDER := mingz2013/riscv-gnu-toolchain-builder:1.0
TOOL := mingz2013/riscv-gnu-toolchain:1.0

BASEDIR=$(CURDIR)

RISCV := $(BASEDIR)/bin/riscv
RISCV-SRC := $(BASEDIR)/src/riscv-gnu-toolchain

RISCV-IN := /opt/riscv
RISCV-SRC-IN := /riscv-gnu-toolchain

#RISCV-BUILD-DIR = $(RISCV-SRC)/build

DOCKER-RUN := docker run --rm -i -t -v${RISCV}:${RISCV-IN} -v${RISCV-SRC}:${RISCV-SRC-IN} ${BUILDER}

.PHONY: git-clone
git-clone:
	git clone --recursive https://github.com/riscv/riscv-gnu-toolchain ${RISCV-SRC}
	#git clone https://github.com/riscv/riscv-gnu-toolchain ${RISCV-SRC}
	#cd ${RISCV-SRC} && git submodule update --init --recursive

.PHONY: builder
builder:
	docker build ./builder -t ${BUILDER}
	#docker push ${BUILDER}

.PHONY: build-make-newlib-32
build-make-newlib-32:
	#rm -r ${RISCV-BUILD-DIR}
	${DOCKER-RUN} ${RISCV-SRC-IN}/configure --prefix=${RISCV-IN} --with-arch=rv32imacfd --with-abi=ilp32d
	${DOCKER-RUN} make
	#${DOCKER-RUN} make report-newlib

.PHONY: build-make-newlib-64
build-make-newlib-64:
	#rm -r ${RISCV-BUILD-DIR}
	${DOCKER-RUN} ${RISCV-SRC-IN}/configure --prefix=${RISCV-IN}
	${DOCKER-RUN} make
	#${DOCKER-RUN} make report-newlib

.PHONY: build-make-newlib-multilib
build-make-newlib-multilib:
	#rm -r ${RISCV-BUILD-DIR}
	${DOCKER-RUN} ${RISCV-SRC-IN}/configure --prefix=${RISCV-IN} --enable-multilib
	${DOCKER-RUN} make
	#${DOCKER-RUN} make report-newlib

.PHONY: build-make-linux-32
build-make-linux-32:
	#rm -r ${RISCV-BUILD-DIR}
	${DOCKER-RUN} ${RISCV-SRC-IN}/configure --prefix=${RISCV-IN} --with-arch=rv32imacgfd --with-abi=ilp32d
	${DOCKER-RUN} make linux
	#${DOCKER-RUN} make report-linux



.PHONY: build-make-linux-64
build-make-linux-64:
	#rm -r ${RISCV-BUILD-DIR}
	${DOCKER-RUN} ${RISCV-SRC-IN}/configure --prefix=${RISCV-IN}
	${DOCKER-RUN} make linux
	#${DOCKER-RUN} make report-linux




.PHONY: build-make-linux-multilib
build-make-linux-multilib:
	#rm -r ${RISCV-BUILD-DIR}
	${DOCKER-RUN} ${RISCV-SRC-IN}/configure --prefix=${RISCV-IN} --enable-multilib
	${DOCKER-RUN} make linux
	#${DOCKER-RUN} make report-linux


.PHONY: build
build:  build-make-newlib-32 build-make-newlib-64  build-make-newlib-multilib build-make-linux-32 build-make-linux-64  build-make-linux-multilib


.PHONY: tool-chain
tool-chain: build
	docker build ./bin -t ${TOOL}
	docker push ${TOOL}



