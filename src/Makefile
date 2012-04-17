# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Copyright 2008 Jean Privat <jean@pryen.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

NITCOPT=

all: ../bin/nitc ../bin/nitdoc ../bin/nits

../bin/nitc: ../c_src/nitc parser/parser.nit
	@echo '***************************************************************'
	@echo '* Compile nitc from NIT source files                          *'
	@echo '***************************************************************'
	./git-gen-version.sh
	../c_src/nitc ${NITCOPT} --clibdir ../c_src/clib -o ../bin/nitc -O -v nitc.nit

../bin/nitdoc: ../bin/nitc
	@echo '***************************************************************'
	@echo '* Compile nitdoc from NIT source files                        *'
	@echo '***************************************************************'
	./git-gen-version.sh
	../bin/nitc ${NITCOPT} -o ../bin/nitdoc -O -v nitdoc.nit

../bin/nits: ../bin/nitc
	@echo '***************************************************************'
	@echo '* Compile nits from NIT source files                        *'
	@echo '***************************************************************'
	./git-gen-version.sh
	../bin/nitc ${NITCOPT} -o ../bin/nits -O -v nits.nit

../c_src/nitc: ../c_src/*.c ../c_src/*.h ../c_src/nitc._build.sh ../c_src/Makefile
	@echo '***************************************************************'
	@echo '* Compile nitc from C source files                            *'
	@echo '***************************************************************'
	cd ../c_src; make

parser/parser.nit:
	@echo '***************************************************************'
	@echo '* Generate nit parser                                         *'
	@echo '***************************************************************'
	cd parser; make

clean:
	rm -rf -- .nit_compile* nit_version.nit 2> /dev/null || true
	cd parser; make clean

distclean: clean
	cd parser; make distclean