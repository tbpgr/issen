# Issen

Issen is files and directories generator by Emmet-like syntax.

## Installation

Add this line to your application's Gemfile:

    gem 'issen'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install issen

## Syntax List
| syntax          | mean                                           |
|:-----------     |:------------                                   |
|~                |nest file or directory inside                   |
|\+               |to place file or directory on the same level    |
|-                |to place file or directory on the same level - 1|

## Usage
### create Issenfile
~~~bash
issen init
~~~

Issenfile
~~~ruby
# encoding: utf-8

# output directory
# output_dir is required
# output_dir allow only String
# output_dir's default value => "output directory name"
output_dir "output directory name"
~~~

### edit Issenfile
Issenfile
~~~ruby
# encoding: utf-8
output_dir "output"
~~~

### output examples
* 1directory case
to create directory, 'd_xxxx'. xxx equals directory_name

~~~bash
issen e 'd_hoge'
~~~

~~~output
└─output
   └─hoge
~~~

* file case

~~~bash
issen e 'hoge.txt'
~~~

~~~output
└─output
   └─hoge.txt
~~~

* &gt; case

~~~bash
issen e 'd_hoge1~hoge2.txt'
~~~

~~~output
└─output
   └─hoge1
           hoge2.txt
~~~

* + case

~~~bash
issen e 'd_hoge1+hoge2.txt'
~~~

~~~output
└─output
   │  hoge2.txt
   │
   └─hoge1
~~~


* ^ case

~~~bash
issen e 'd_hoge1~d_hoge2~hoge3.txt-hoge2_2.txt'
~~~

~~~output
└─output
    └─hoge1
        │  hoge2_2.txt
        │
        └─hoge2
                hoge3.txt
~~~

## History
* version 0.0.1  : first release.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
