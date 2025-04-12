#+title: Emacs Lisp Elements
#+author: Protesilaos Stavrou
#+email: info@protesilaos.com
#+language: en
#+options: ':t toc:nil author:t email:t num:t
#+startup: content
#+macro: stable-version 1.0.0
#+macro: release-date 2025-04-12
#+macro: kbd @@texinfo:@kbd{@@$1@@texinfo:}@@
#+texinfo_filename: elispelem.info
#+texinfo_dir_category: Emacs misc features
#+texinfo_dir_title: Emacs Lisp Elements: (elispelem)
#+texinfo_dir_desc: A big picture view of Emacs Lisp
#+texinfo_header: @set MAINTAINERSITE @uref{https://protesilaos.com,maintainer webpage}
#+texinfo_header: @set MAINTAINER Protesilaos Stavrou
#+texinfo_header: @set MAINTAINEREMAIL @email{info@protesilaos.com}
#+texinfo_header: @set MAINTAINERCONTACT @uref{mailto:info@protesilaos.com,contact the maintainer}

#+texinfo: @insertcopying

This book, written by Protesilaos Stavrou, also known as "Prot", provides a big picture view of the Emacs Lisp programming language.

The information furnished herein corresponds to stable version {{{stable-version}}}, released on {{{release-date}}}.

+ Official page: <https://protesilaos.com/emacs/emacs-lisp-elements>
+ Git repository: <https://github.com/protesilaos/emacs-lisp-elements>

#+toc: headlines 8 insert TOC here, with eight headline levels

* Getting started with Emacs Lisp
:PROPERTIES:
:CUSTOM_ID: h:getting-started-with-emacs-lisp
:END:

The purpose of this book is to provide you with a big picture view of Emacs Lisp, also known as "Elisp". This is the programming language you use to extend Emacs. Emacs is a programmable text editor: it interprets Emacs Lisp and behaves accordingly. You can use Emacs without ever writing a single line of code: it already has lots of features. Though you can, at any time, program it to do exactly what you want by evaluating some Elisp that either you wrote yourself or got from another person, such as in the form of a package.

Programming your own text editor is both useful and fun. You can, for example, streamline a sequence of actions you keep doing by combining them in a single command that you then assign to a key binding: type the key and---bam!---perform all the intermediate tasks in one go. This makes you more efficient while it turns the editor into a comfortable working environment.

The fun part is how you go about writing the code. There are no duties you have to conform with. None! You program for the sake of programming. It is a recreational activity that expands your horizons. Plus, you cultivate your Elisp skills, which can prove helpful in the future, should you choose to modify some behaviour of Emacs.

Tinkering with Emacs is part of the experience. It teaches you to be unapologetically opinionated about how your editor works. The key is to know enough Elisp so that you do not spend too much time having fun or getting frustrated because something trivial does not work. I am writing this as a tinkerer myself with no background in computer science or neighbouring studies: I learnt Emacs Lisp through trial and error by playing around with the editor. My nominal goal was to improve certain micro-motions I was repeating over and over: I sought efficiency only to discover something much more profound. Learning to extend my editor has been a fulfilling experience and I am more productive as a result. Emacs does what I want it to do and I am happy with it.

Each chapter herein is generally short and to-the-point. Some are more friendly to beginners while others dive deeper into advanced topics. There are links between the chapters, exactly how a reference manual is supposed to be done. You may then go back and forth to find what you need.

The text you will find here is a combination of prose and code. The latter may be actual Elisp or pseudo-code which captures the underlying pattern. I encourage you to read this book either inside of Emacs or with Emacs readily available. This way, you can play around with the functions I give you, to further appreciate their nuances.

The "big picture view" approach I am adopting is about covering the concepts that I encounter frequently while working with Emacs Lisp. This book is no substitute for the Emacs Lisp Reference Manual and should by no means be treated as the source of truth for any of the Elisp forms I comment on.

Good luck and enjoy!

* Evaluate Emacs Lisp
:PROPERTIES:
:CUSTOM_ID: h:evaluate-emacs-lisp
:END:

Everything you do in Emacs calls some function. It evaluates Emacs Lisp code, reading the return values and producing side effects ([[#h:side-effect-and-return-value][Side effect and return value]]).

#+findex: Interactive functions are commands
You type a key on your keyboard and a character is written to the current buffer. That is a function bound to a key. It actually is an /interactive/ function, because you are calling it via a key binding rather than through some program. Interactive functions are known as "commands". Though do not let the implementation detail of interactivity distract you from the fact that every single action you perform in Emacs involves the evaluation of Emacs Lisp.

#+findex: execute-extended-command
Another common pattern of interaction is with the {{{kbd(M-x)}}} (~execute-extended-command~) key, which by default runs the command ~execute-extended-command~: it produces a minibuffer prompt that asks you to select a command by its name and proceeds to execute it.

#+findex: eval-last-sexp
#+findex: eval-buffer
#+findex: eval-region
Emacs can evaluate Elisp code from anywhere. If you have some Elisp in your buffer, you can place the cursor at the end of its closing parenthesis and type {{{kbd(C-x C-e)}}} (~eval-last-sexp~). Similarly, you can use the commands ~eval-buffer~ and ~eval-region~ to operate on the current buffer or highlighted region, respectively.

#+vindex: buffer-file-name
The ~eval-last-sexp~ also works on symbols ([[#h:symbols-balanced-expressions-and-quoting][Symbols, balanced expressions, and quoting]]). For example, if you place the cursor at the end of the variable ~buffer-file-name~ and use {{{kbd(C-x C-e)}}} (~eval-last-sexp~), you will get the value of that variable, which is either ~nil~ or the file system path to the file you are editing.

#+findex: eval-expression
Sometimes the above are not appropriate for what you are trying to do. Suppose you intend to write a command that copies the file path of the current buffer. To do that, you need your code to test the value of the variable ~buffer-file-name~ ([[#h:buffers-as-data-structures][Buffers as data structures]]). But you do not want to type out ~buffer-file-name~ in your actual file, then use one of the aforementioned commands for Elisp evaluation, and then undo your edits. That is cumbersome and prone to mistakes! The best way to run Elisp in the current buffer is to type {{{kbd(M-:)}}} (~eval-expression~): it opens the minibuffer and expects you to write the code you want to evaluate. Type {{{kbd(RET)}}} from there to proceed. The evaluation is done with the last buffer as current (the buffer that was current prior to calling ~eval-expression~).

Here is some Emacs Lisp you may want to try in (i) a buffer that corresponds to a file versus (ii) a buffer that is not associated with any file on disk.

#+begin_src emacs-lisp
;; Use `eval-expression' to evaluate this code in a file-visiting
;; buffer versus a buffer that does not visit any file.
(if buffer-file-name
    (message "The path to this file is `%s'" buffer-file-name)
  (message "Sorry mate, this buffer is not visiting a file"))
#+end_src

#+findex: ielm
#+findex: lisp-interaction-mode
#+vindex: initial-major-mode
#+findex: eval-print-last-sexp
#+findex: eval-last-sexp
When you are experimenting with code, you want to test how it behaves. Use the command ~ielm~ to open an interactive shell. It puts you at a prompt where you can type any Elisp and hit {{{kbd(RET)}}} to evaluate it. The return value is printed right below. Alternatively, switch to the =*scratch*= buffer. If it is using the major mode ~lisp-interaction-mode~, which is the default value of the variable ~initial-major-mode~, then you can move around freely in that buffer and type {{{kbd(C-j)}}} (~eval-print-last-sexp~) at the end of some code to evaluate it. This works almost the same way as ~eval-last-sexp~, with the added effect of putting the return value right below the expression you just evaluated.

#+cindex: Introspect Emacs Lisp
#+vindex: major-mode
#+findex: describe-variable
#+findex: describe-function
#+findex: describe-keymap
#+findex: describe-key
#+findex: describe-symbol
In addition to these, you can rely on the self-documenting nature of Emacs to figure out what the current state is. For example, to learn about the buffer-local value of the variable ~major-mode~, you can do {{{kbd(C-h v)}}} (~describe-variable~), and then search for that variable. The resulting Help buffer will inform you about the current value of ~major-mode~. This help command and many others like ~describe-function~, ~describe-keymap~, ~describe-key~, and ~describe-symbol~, provide insight into what Emacs knows about a given object. The Help buffer will show relevant information, such as the path to the file that defines the given function or whether a variable is declared as buffer-local.

#+cindex: Emacs is self-documenting
Emacs is "self-documenting" because it reports on its state. You do not need to explicitly update the Help buffers. This happens automatically by virtue of evaluating the relevant code: Emacs effectively shows you the latest value of whatever it is you are working with.

* Side effect and return value
:PROPERTIES:
:CUSTOM_ID: h:side-effect-and-return-value
:END:

Emacs Lisp has functions. They take inputs and produce outputs. In its purest form, a function is a computation that only returns a value: it does not change anything in its environment. The return value of a function is used as input for another function, in what effectively is a chain of computations. You can thus rely on a function's return value to express something like "if this works, then also do this other thing, otherwise do something else or even nothing."

Elisp is the language that extends and controls Emacs. This means that it also affects the state of the editor. When you run a function, it can make permanent changes, such as to insert some text at the point of the cursor, delete a buffer, create a new window, and so on. These changes will have an impact on future function calls. For example, if the previous function deleted a certain buffer, the next function which was supposed to write to that same buffer can no longer do its job: the buffer is gone!

When you write Elisp, you have to account for both the return value and the side effects. If you are sloppy, you will get unintended results caused by all those ill-considered changes to the environment. But if you use side effects meticulously, you are empowered to take Elisp to its full potential. For instance, imagine you define a function that follows the logic of "create a buffer, go there, write some text, save the buffer to a file at my preferred location, and then come back where I was before I called this function, while leaving the created buffer open." All these are side effects and they are all useful. Your function may have some meaningful return value as well that you can employ as the input of another function. For example, your function would return the buffer object it generated, so that the next function can do something there like display that buffer in a separate frame and make its text larger.

The idea is to manipulate the state of the editor, to make Emacs do what you envision. Sometimes this means your code has side effects. At other times, side effects are useless or even run counter to your intended results. You will keep refining your intuition about what needs to be done as you gain more experience and expand the array of your skills ([[#h:symbols-balanced-expressions-and-quoting][Symbols, balanced expressions, and quoting]]). No problem; no stress!

* Buffers as data structures
:PROPERTIES:
:CUSTOM_ID: h:buffers-as-data-structures
:END:

#+findex: point
#+findex: point-min
#+findex: point-max
#+findex: line-beginning-position
#+findex: re-search-forward
A buffer holds data as a sequence of characters. For example, this data is the text you are looking at when you open a file. Each character exists at a given position, which is a number. The function ~point~ gives you the position at the point you are on, which typically corresponds to where the cursor is ([[#h:evaluate-emacs-lisp][Evaluate Emacs Lisp]]). At the beginning of a buffer, ~point~ returns the value of =1= ([[#h:side-effect-and-return-value][Side effect and return value]]). There are plenty of functions that return a buffer position, such as ~point-min~, ~point-max~, ~line-beginning-position~, and ~re-search-forward~. Some of those will have side effects, like ~re-search-forward~ which moves the cursor to the given match.

When you program in Emacs Lisp, you frequently rely on buffers to do some of the following:

#+findex: buffer-string
#+findex: buffer-substring
#+findex: buffer-substring-no-properties
- Extract file contents as a string :: Think of the buffer as a large string. You can get the entirety of its contents as one potentially massive string by using the function ~buffer-string~. You may also get a substring between two buffer positions, such as with the ~buffer-substring~ function or its ~buffer-substring-no-properties~ counterpart ([[#h:text-has-its-own-properties][Text has its own properties]]). Imagine you do this as part of a wider operation that (i) opens a file, (ii) goes to a certain position, (iii) copies the text it found, (iv) switches to another buffer, and (v) writes what it found to this new buffer.

#+findex: get-buffer-create
#+findex: get-buffer
#+findex: with-current-buffer
#+findex: erase-buffer
#+findex: delete-region
#+findex: display-buffer
#+findex: pop-to-buffer
- Present the results of some operation :: You may have a function that shows upcoming holidays. Your code does the computations behind the scenes and ultimately writes some text to a buffer. The end product is on display. Depending on how you go about it, you will want to evaluate the function ~get-buffer-create~ or its more strict ~get-buffer~ alternative. If you need to clear the contents of an existing buffer, you might use the ~with-current-buffer~ macro to temporarily switch to the buffer you are targetting and then either call the function ~erase-buffer~ to delete everything or limit the deletion to the range betweeen two buffer positions with ~delete-region~. Finally, the functions ~display-buffer~ or ~pop-to-buffer~ will place the buffer in an Emacs window.

#+vindex: buffer-file-name
#+vindex: fill-column
#+vindex: default-directory
#+vindex: buffer-list
#+findex: setq-local
- Associate variables with a given buffer :: In Emacs Lisp, variables can take a buffer-local value which differs from its global counterpart. Some variables are even declared to always be buffer-local, such as the ~buffer-file-name~, ~fill-column~, and ~default-directory~. Suppose you are doing something like returning a list of buffers that visit files in a given directory. You would iterate through the return value of the ~buffer-list~ function to filter the results accordingly by testing for a certain value of ~buffer-file-name~ ([[#h:basic-control-flow-with-if-cond-and-others][Basic control flow with ~if~, ~cond~, and others]]). This specific variable is always available, though you can always use the ~setq-local~ macro to assign a value to a variable in the current buffer.

#+findex: seq-filter
#+findex: buffer-list
#+cindex: Hidden buffers
The latter point is perhaps the most open-ended one. Buffers are like a bundle of variables, which includes their contents, the major mode they are running, and all the buffer-local values they have. In the following code block, I am using the ~seq-filter~ function to iterate through the return value of the function ~buffer-list~ ([[#h:symbols-balanced-expressions-and-quoting][Symbols, balanced expressions, and quoting]]).

#+begin_src emacs-lisp
(seq-filter
 (lambda (buffer)
   "Return BUFFER if it is visible and its major mode derives from `text-mode'."
   (with-current-buffer buffer
     ;; The convention for buffers which are not meant to be seen by
     ;; the user is to start their name with an empty space.  We are
     ;; not interested in those right now.
     (and (not (string-prefix-p " " (buffer-name buffer)))
          (derived-mode-p 'text-mode))))
 (buffer-list))
#+end_src

This will return a list of buffer objects that pass the test of (i) being "visible" to the user and (ii) their major mode is either ~text-mode~ or derived therefrom. The above may also be written thus ([[#h:when-to-use-a-named-function-or-a-lambda-function][When to use a named function or a lambda function]]):

#+begin_src emacs-lisp
(defun my-buffer-visble-and-text-p (buffer)
  "Return BUFFER if it is visible and its major mode derives from `text-mode'."
  (with-current-buffer buffer
    ;; The convention for buffers which are not meant to be seen by
    ;; the user is to start their name with an empty space.  We are
    ;; not interested in those right now.
    (and (not (string-prefix-p " " (buffer-name buffer)))
         (derived-mode-p 'text-mode))))

(seq-filter #'my-buffer-visble-and-text-p (buffer-list))
#+end_src

As with buffers, Emacs windows and frames have their own parameters. I will not cover those as their utility is more specialised and the concepts are the same. Just know that they are data structures that you may use to your advantage, including by iterating through them ([[#h:mapping-through-a-list-of-elements][Mapping through a list of elements]]).

* Text has its own properties
:PROPERTIES:
:CUSTOM_ID: h:text-has-its-own-properties
:END:

#+cindex: Propertise text
#+cindex: Fontify text
#+cindex: Faces
#+findex: describe-char
Just as with buffers that work like data structures ([[#h:buffers-as-data-structures][Buffers as data structures]]), any text may also have properties associated with it. This is metadata that you inspect using Emacs Lisp. For example, when you see syntax highlighting in some programming buffer, this is the effect of text properties. Some function takes care to "propertise" or to "fontify" the relevant text and decides to apply to it an object known as "face". Faces are constructs that bundle together typographic and colour attributes, such as the font family and weight, as well as foreground and background hues. To get a Help buffer with information about the text properties at the point of the cursor, type {{{kbd(M-x)}}} (~execute-extended-command~) and then invoke the command ~describe-char~. It will tell you about the character it sees, what font it is rendered with, which code point it is, and what its text properties are.

Suppose you are writings your own major mode. At the early stage of experimentation, you want to manually add text properties to all instances of the phrase =I have properties= in a buffer whose major mode is ~fundamental-mode~, so you do something like this ([[#h:the-match-data-of-the-last-search][The match data of the last search]]):

#+begin_src emacs-lisp
(defun my-add-properties ()
  "Add properties to the text \"I have properties\" across the current buffer."
  (goto-char (point-min))
  (while (re-search-forward "I have properties" nil t)
    (add-text-properties (match-beginning 0) (match-end 0) '(face error))))
#+end_src

Actually try this. Use {{{kbd(C-x b)}}} (~switch-to-buffer~), type in some random characters that do not match an existing buffer, and then hit {{{kbd(RET)}}} to visit that new buffer. It runs ~fundamental-mode~, meaning that there is no "fontification" happening and, thus, ~my-add-properties~ will work as intented. Now paste the following:

#+begin_src fundamental
This is some sample text. Will the phrase "I have properties" use the `bold' face?

What does it even mean for I have properties to be bold?
#+end_src

Continue with {{{kbd(M-:)}}} (~eval-expression~) and call the function ~my-add-properties~. Did it work? The face it is applying is called ~error~. Ignore the semantics of that word: I picked it simply because it typically is styled in a fairly intense and obvious way (though your current theme may do things differently).

#+findex: shortdoc
#+cindex: Shortdoc for text properties
There are functions which find the properties at a given buffer position and others which can search forward and backward for a given property. The specifics do not matter right now. All I want you to remember is that the text can be more than just its constituent characters. For more details, type {{{kbd(M-x)}}} (~execute-extended-command~) to call the command ~shortdoc~. It will ask you for a documentation group. Pick =text-properties= to learn more. Well, use ~shortdoc~ for everything listed there. I do it all the time.

* Symbols, balanced expressions, and quoting
:PROPERTIES:
:CUSTOM_ID: h:symbols-balanced-expressions-and-quoting
:END:

#+cindex: Define a simple function
To someone not familiar with Emacs Lisp, it is a language that has so many parentheses! Here is a simple function definition:

#+begin_src emacs-lisp
(defun my-greet-person (name)
  "Say hello to the person with NAME."
  (message "Hello %s" name))
#+end_src

#+findex: message
#+findex: view-echo-area-messages
I just defined the function with the name ~my-greet-person~. It has a list of parameters, specifically, a list of one parameter, called =name=. Then is the optional documentation string, which is for users to make sense of the code and/or understand the intent of the function. ~my-greet-person~ takes =name= and passes it to the function ~message~ as an argument to ultimately print a greeting. The ~message~ function logs the text in the =*Messages*= buffer, which you can visit directly with {{{kbd(C-h e)}}} (~view-echo-area-messages~). At any rate, this is how you call ~my-greet-person~ with the one argument it expects:

#+begin_src emacs-lisp
(my-greet-person "Protesilaos")
#+end_src

Now do the same with more than one parameters:

#+begin_src emacs-lisp
(defun my-greet-person-from-country (name country)
  "Say hello to the person with NAME who lives in COUNTRY."
  (message "Hello %s of %s" name country))
#+end_src

And call it thus:

#+begin_src emacs-lisp
(my-greet-person-from-country "Protesilaos" "Cyprus")
#+end_src

Even for the most basic tasks, you have lots of parentheses. But fear not! These actually make it simpler to have a structural understanding of your code. If it does not feel this way right now, it is because you are not used to it yet. Once you do, there is no going back.

#+cindex: Lisp languages are all about lists
The basic idea of any dialect of Lisp, Emacs Lisp being one of them, is that you have parentheses which delimit lists. A list consists of elements. Lists are either evaluated to produce the results of some computation or returned as they are for use in some other evaluation ([[#h:side-effect-and-return-value][Side effect and return value]]):

- The list as a function call :: When a list is evaluated, the first element is the name of the function and the remaining elements are the arguments passed to it. You already saw this play out above with how I called ~my-greet-person~ with ="Protesilaos"= as its argument. Same principle for ~my-greet-person-from-country~, with ="Protesilaos"= and ="Cyprus"= as its arguments.

- The list as data :: When a list is not evaluated, then none of its elements has any special meaning at the outset. They are all returned as a list without further changes. When you do not want your list to be evaluated, you prefix it with a single quote character. For example, ='("Protesilaos" "Prot" "Cyprus")= is a list of three elements that should be returned as-is.

#+findex: car
#+findex: cdr
Consider the latter case, which you have not seen yet. You have a list of elements and you want to get some data out of it. At the most basic level, the functions ~car~ and ~cdr~ return the first element and the list of all remaining elements, respectively:

#+begin_src emacs-lisp
(car '("Protesilaos" "Prot" "Cyprus"))
;; => "Protesilaos"

(cdr '("Protesilaos" "Prot" "Cyprus"))
;; => ("Prot" "Cyprus")
#+end_src

The single quote here is critical, because it instructs Emacs to not evaluate the list. Otherwise, the evaluation of this list would treat the first element, namely ="Protesilaos"=, as the name of a function and the remainder of the list as the arguments to that function. As you do not have the definition of such a function, you get an error.

#+findex: list
#+cindex: Self-evaluating objects
Certain data types in Emacs Lisp are "self-evaluating". This means that if you evaluate them, their return value is what you are already seeing. For example, the return value of the string of characters ="Protesilaos"= is ="Protesilaos"=. This is true for strings, numbers, keywords, symbols, and the special ~nil~ or ~t~. Here is a list with a sample of each of these, which you construct by calling the function ~list~:

#+begin_src emacs-lisp
(list "Protesilaos" 1 :hello 'my-greet-person-from-country nil t)
;; => ("Protesilaos" 1 :hello 'my-greet-person-from-country nil t)
#+end_src

The ~list~ function evaluates the arguments passed to it, unless they are quoted. The reason you get the return value without any apparent changes is because of self-evaluation. Notice that ~my-greet-person-from-country~ is quoted the same way we quote a list we do not want to evaluate. Without it, ~my-greet-person-from-country~ would be evaluated, which would return an error unless that was also defined as a variable.

#+cindex: Quote to avoid evaluation
Think of the single quote as an unambiguous instruction: "do not evaluate the following." More specifically, it is an instruction to not perform evaluation if it would have normally happened in that context ([[#h:partial-evaluation-inside-of-a-list][Partial evaluation inside of a list]]). In other words, you do not want to quote something inside of a quoted list, because that is the same as quoting it twice:

#+begin_src emacs-lisp
;; This is the correct way:
'(1 :hello my-greet-person-from-country)

;; It is wrong to quote `my-greet-person-from-country' because the
;; entire list would not have been evaluated anyway.  The mistake here
;; is that you are quoting what is already quoted, like doing
;; ''my-greet-person-from-country.
'(1 :hello 'my-greet-person-from-country)
#+end_src

#+cindex: Self-quoting objects
#+cindex: Unquoted symbols are evaluated
Now you may be wondering why did we quote ~my-greet-person-from-country~ but nothing else? The reason is that everything else you saw there is effectively "self-quoting", i.e. the flip-side of self-evaluation. Whereas ~my-greet-person-from-country~ is a symbol. A "symbol" is a reference to something other than itself: it either represents some computation---a function---or the value of a variable. If you write a symbol without quoting it, you are effectively telling Emacs "give me the value this symbol represents." In the case of ~my-greet-person-from-country~, you will get an error if you try that because this symbol is not a variable and thus trying to get a value out of it is not going to work.

#+concept: Elisp Macros
Keep in mind that Emacs Lisp has a concept of "macro", which basically is a templating system to write code that actually expands into some other code which is then evaluated. Inside of a macro, you control how quoting is done, meaning that the aforementioned may not apply to calls that involve the macro, even if they are still used inside of the macro's expanded form ([[#h:evaluation-inside-of-a-macro-or-special-form][Evaluation inside of a macro or special form]]).

#+findex: quote
#+findex: function
As you expose yourself to more Emacs Lisp code, you will encounter quotes that are preceded by the hash sign, like =#'some-symbol=. This "sharp quote", as it is called, is the same as the regular quote with the added semantics of referring to a function in particular. The programmer can thus better articulate the intent of a given expression, while the byte compiler may internally perform the requisite checks and optimisations. In this light, read about the functions ~quote~ and ~function~ which correspond to the quote and sharp quote, respectively.

* Partial evaluation inside of a list
:PROPERTIES:
:CUSTOM_ID: h:partial-evaluation-inside-of-a-list
:END:

You already have an idea of how Emacs Lisp code looks like ([[#h:symbols-balanced-expressions-and-quoting][Symbols, balanced expressions, and quoting]]). You have a list that is either evaluated or taken as-is. There is another case where a list should be partially evaluated or, more specifically, where it should be treated as data instead of a function call with some elements inside of it still subject to evaluation.

#+cindex: Declare a variable
In the following code block, I am defining a variable called ~my-greeting-in-greek~, which is a common phrase in Greek that literally means "health to you" and is pronounced as "yah sou". Why Greek? Well, you got the ~lambda~ that engendered this whole business with Lisp, so you might as well get all the rest ([[#h:when-to-use-a-named-function-or-a-lambda-function][When to use a named function or a lambda function]])!

#+begin_src emacs-lisp
(defvar my-greeting-in-greek "Γεια σου"
  "Basic greeting in Greek to wish health to somebody.")
#+end_src

#+findex: message
Now I want to experiment with the ~message~ function to better understand how evaluation works. Let me start with the scenario of quoting the list, thus taking it as-is:

#+begin_src emacs-lisp
(message "%S" '(one two my-greeting-in-greek four))
;;=> "(one two my-greeting-in-greek four)"
#+end_src

You will notice that the variable ~my-greeting-in-greek~ is not evaluated. I get the symbol, the actual ~my-greeting-in-greek~, but not the value it represents. This is the expected result, because the entire list is quoted and, ipso facto, everything inside of it is not evaluated.

Now check the next code block to understand how I can tell Emacs that I want the entire list to still be quoted but for ~my-greeting-in-greek~ in particular to be evaluated, so it is replaced by its value:

#+begin_src emacs-lisp
(message "%S" `(one two ,my-greeting-in-greek four))
;; => "(one two \"Γεια σου\" four)"
#+end_src

#+findex: concat
#+cindex: Quasi quote
#+cindex: Comma operator
Pay close attention to the syntax here. Instead of a single quote, I am using the backtick or back quote, which is also known as a "quasi quote" in our case. This behaves like the single quote except for anything that is preceded by a comma. The comma is an instruction to "evaluate the thing that follows" and only works inside of a quasi-quoted list. The "thing" that follows is either a symbol or a list. The list can, of course, be a function call. Let me then use ~concat~ to greet a certain person all while returning everything as a list:

#+begin_src emacs-lisp
(message "%S" `(one two ,(concat my-greeting-in-greek " " "Πρωτεσίλαε") four))
;; => "(one two \"Γεια σου Πρωτεσίλαε\" four)"
#+end_src

Bear in mind that you would get an error if you were not quoting this list at all, because the first element ~one~ would be treated as the symbol a function, which would be called with all other elements as its arguments. Chances are that ~one~ is not defined as a function in your current Emacs session or those arguments are not meaningful to it, anyway. Plus, ~two~ and ~four~ would then be treated as variables, since they are not quoted, in which case those would have to be defined as well, else more errors would ensue.

#+cindex: Splicing in general
Other than the comma operator, there is the =,@= (how is this even pronounced? "comma at", perhaps?), which is notation for "splicing". This is jargon in lieu of saying "the return value is a list and I want you to remove the outermost parentheses of it." In effect, the code that would normally return ='(one two three)= now returns =one two three=. This difference may not make much sense in a vacuum, though it does once you consider those elements as expressions that should work in their own right, rather than simply be elements of a quoted list. I will not elaborate on an example here, as I think this is best covered in the context of defining macros ([[#h:evaluation-inside-of-a-macro-or-special-form][Evaluation inside of a macro or special form]]).

Chances are you will not need to use the knowledge of partial evaluation. It is more common in macros, though can be applied anywhere. Be aware of it regardless, as there are scenaria where you will, at the very least, want to understand what some code you depend on is doing.

Lastly, since I introduced you to some Greek words, I am now considering you my friend. Here is a joke from when I was a kid. I was trying to explain some event to my English instructor. As I lacked the vocabulary to express myself, I started using Greek words. My instructor had a strict policy of only responding to English, so she said "It is all Greek to me." Not knowing that her answer is an idiom for "I do not understand you", I blithely replied, "Yes, Greek madame; me no speak England very best." I was not actually a beginner at the time, though I would not pass on the opportunity to make fun of the situation. Just how you should remember to enjoy the time spent tinkering with Emacs. But enough of that! Back to reading this book.

* Evaluation inside of a macro or special form
:PROPERTIES:
:CUSTOM_ID: h:evaluation-inside-of-a-macro-or-special-form
:END:

In the most basic case of Emacs Lisp code, you have lists that are either evaluated or not ([[#h:symbols-balanced-expressions-and-quoting][Symbols, balanced expressions, and quoting]]). If you get a little more fancy, you have lists that are only partially evaluated ([[#h:partial-evaluation-inside-of-a-list][Partial evaluation inside of a list]]). Sometimes though, you look at a piece of code and cannot understand why the normal rules of quoting and evaluation do not apply. Before you see this in action, inspect a typical function call that also involves the evaluation of a variable:

#+begin_src emacs-lisp
(concat my-greeting-in-greek " " "Πρωτεσίλαε")
#+end_src

#+findex: concat
#+cindex: Evaluation inside of a function call
You encountered this code in the section about partial evaluation. What you have here is a call to the function ~concat~, followed by three arguments. One of these arguments is a variable, the ~my-greeting-in-greek~. When this list is evaluated, what Emacs actually does is to first evaluate the arguments, including ~my-greeting-in-greek~, in order to get their respective values and only then to call ~concat~ with those values. You can think of the entire operation as follows:

- Here is a list.
- It is not quoted.
- So you should evaluate it.
- The first element is the name of the function.
- The remaining elements are arguments passed to that function.
- Check what the arguments are.
- Evaluate each of the arguments to resolve it to its actual value.
- Strings are self-evaluating, while the ~my-greeting-in-greek~ is a variable.
- You now have the value of each of the arguments, including the value of the symbol ~my-greeting-in-greek~.
- Call ~concat~ with all the values you got.

In other words, the following two yield the same results (assuming a constant ~my-greeting-in-greek~):

#+begin_src emacs-lisp
(concat my-greeting-in-greek " " "Πρωτεσίλαε")

(concat "Γεια σου" " " "Πρωτεσίλαε")
#+end_src

#+findex: setq
This is predictable. It follows the basic logic of the single quote: if it is quoted, do not evaluate it and return it as-is, otherwise evaluate it and return its value. But you will find plenty of cases where this expected pattern is seemingly not followed. Consider this common case of using ~setq~ to bind a symbol to the given value:

#+begin_src emacs-lisp
(setq my-test-symbol "Protesilaos of Cyprus")
#+end_src

The above expression looks like a function call, meaning that (i) the list is not quoted, (ii) the first element is the name of a function, and (iii) the remaining elements are arguments passed to that function. In a way, this is all true. Though you would then expect the ~my-test-symbol~ to be treated as a variable, which would be evaluated in place to return its result which would, in turn, be the actual argument passed to the function. However, this is not how ~setq~ works. The reason is that it is a special case that internally does this:

#+begin_src emacs-lisp
(set 'my-test-symbol "Protesilaos of Cyprus")
#+end_src

#+findex: setq
#+findex: defun
This is where things are as expected. There is no magic happening behind the scenes. The ~setq~, then, is a convenience for the user to not quote the symbol each time. Yes, this makes it a bit more difficult to reason about it, though you get used to it and eventually it all makes sense. Hopefully, you will get used to such special forms, as you find them with ~setq~ but also with ~defun~, among many others. Here is a function you have already seen:

#+begin_src emacs-lisp
(defun my-greet-person-from-country (name country)
  "Say hello to the person with NAME who lives in COUNTRY."
  (message "Hello %s of %s" name country))
#+end_src

If the normal rules of evaluation applied, then the list of parametes should be quoted. Otherwise, you would expect =(name country)= to be interpreted as a function call with ~name~ as the symbol of the function and ~country~ as its argument which would also be a variable. But this is not what is happening because ~defun~ will internally treat that list of parameters as if it was quoted.

#+findex: let
Another common scenario is with ~let~ ([[#h:control-flow-with-if-let-and-friends][Control flow with ~if-let*~ and friends]]). Its general form is as follows:

#+begin_src emacs-lisp
;; This is pseudo-code
(let LIST-OF-LISTS-AS-VARIABLE-BINDINGS
  BODY-OF-THE-FUNCTION)
#+end_src

The =LIST-OF-LISTS-AS-VARIABLE-BINDINGS= is a list in which each element is a list of the form =(SYMBOL VALUE)=. Here is some actual code:

#+begin_src emacs-lisp
(let ((name "Protesilaos")
      (country "Cyprus"))
  (message "Hello %s of %s" name country))
#+end_src

Continuing with the theme of special forms, if ~let~ was a typical function call, the =LIST-OF-LISTS-AS-VARIABLE-BINDINGS= would have to be quoted. Otherwise, it would be evaluated, in which case the first element would be the name of the function. But that would return an error, as the name of the function would correspond to another list, the =(name "Protesilaos")=, rather than a symbol. Things work fine with ~let~ because it internally does the quoting of its =LIST-OF-LISTS-AS-VARIABLE-BINDINGS=.

#+findex: use-package
Expect similar behaviour with many special forms as well as with macros such as the popular ~use-package~, which is used to configure packages inside of your Emacs initialisation file. How each of those macros works depends on the way it is designed. I will not delve into the technicalities here, as I want the book to be useful long-term, focusing on the principles rather than the implementation details that might change over time.

#+findex: pp-macroexpand-last-sexp
#+cindex: Pretty print or expand a macro
To learn what a given macro actually expands to, place the cursor at the end of its closing parenthesis and call the command ~pp-macroexpand-last-sexp~. It will produce a new buffer showing the expanded Emacs Lisp code. This is what is actually evaluated in the macro's stead.

#+findex: defmacro
#+vindex: default-directory
#+cindex: Defining macros
#+cindex: Splicing within a macro
With those granted, it is time to write a macro. This is like a template, which empowers you to not repeat yourself. Syntactically, a macro will most probably depend on the use of the quasi-quote, the comma operator, and the mechanics of splicing ([[#h:partial-evaluation-inside-of-a-list][Partial evaluation inside of a list]]). Here is a simple scenario where we want to run some code in a temporary buffer while setting the ~default-directory~ to the user's home directory.

#+begin_src emacs-lisp
(defmacro my-work-in-temp-buffer-from-home (&rest expressions)
  "Evaluate EXPRESSIONS in a temporary buffer with `default-directory' set to the user's home."
  `(let ((default-directory ,(expand-file-name "~/")))
     (with-temp-buffer
       (message "Running all expression from the `%s' directory" default-directory)
       ,@expressions)))
#+end_src

In this definition, the =&rest= makes the following parameter a list. So you can pass an arbitrary number of arguments to it, all of which will be collected into a single list called =EXPRESSIONS=. The judicious use of partial evaluation ensures that the macro will not be evaluated right now but only when it is called. The arguments passed to it will be placed where you have specified. Here is a call that uses this macro:

#+begin_src emacs-lisp
(progn
  (message "Now we are doing something unrelated to the macro")
  (my-work-in-temp-buffer-from-home
   (message "We do stuff inside the macro")
   (+ 1 1)
   (list "Protesilaos" "Cyprus")))
#+end_src

If you place the cursor at the closing parenthesis of ~my-work-in-temp-buffer-from-home~, you will be able to confirm what it expands to by typing {{{kbd(M-x)}}} (~execute-extended-command~) and then invoking the command ~pp-macroexpand-last-sexp~. This is what I get:

#+begin_src emacs-lisp
(let ((default-directory "/home/prot/"))
  (with-temp-buffer
    (message "Running all expression from the `%s' directory" default-directory)
    (message "We do stuff inside the macro")
    (+ 1 1)
    (list "Protesilaos" "Cyprus")))
#+end_src

Piecing it together with the rest of the code in its context, I arrive at this:

#+begin_src emacs-lisp
(progn
  (message "Now we are doing something unrelated to the macro")
  (let ((default-directory "/home/prot/"))
    (with-temp-buffer
      (message "Running all expression from the `%s' directory" default-directory)
      (message "We do stuff inside the macro")
      (+ 1 1)
      (list "Protesilaos" "Cyprus"))))
#+end_src

With this example in mind, consider Elisp macros to be a way of saying "this little thing here helps me express this larger procedure more succinctly, while the actual code that runs is still that of the latter."

The above macro I wrote has its body start with a quasi-quote, so you do not get to appreciate the nuances of evaluation within it. Let me show you this other approach, instead, where I write a macro that lets me define several almost identical interactive functions ([[#h:make-your-interactive-function-also-work-from-lisp-calls][Make your interactive function also work from Lisp calls]]).

#+begin_src emacs-lisp
(defmacro my-define-command (name &rest expressions)
  "Define command with specifier NAME that evaluates EXPRESSIONS."
  (declare (indent 1))
  (unless (symbolp name)
    (error "I want NAME to be a symbol"))
  (let ((modifined-name (format "modified-version-of-%s" name)))
    `(defun ,(intern modifined-name) ()
       (interactive)
       ,(message "The difference between `%s' and `%s'" modifined-name name)
       ,@expressions)))
#+end_src

The ~my-define-command~ can be broadly divided into two parts: (i) what gets evaluated outright and (ii) what gets expanded for further evaluation. The latter part starts with the quasi-quote. This distinction is important when we call the macro, because the former part will be executed right away so if we hit the error, it will never expand and then run the =EXPRESSIONS=. Try ~pp-macroexpand-last-sexp~ with the following to see what I mean. For your convenience, I include the macro expansions right below each case.

#+begin_src emacs-lisp
(my-define-command first-demo
  (message "This is what my function does")
  (+ 1 10)
  (message "And this"))
;; =>
;;
;; (defun modified-version-of-first-demo nil
;;   (interactive)
;;   "The difference between ‘modified-version-of-first-demo’ and ‘first-demo’"
;;   (message "This is what my function does")
;;   (+ 1 10)
;;   (message "And this"))


(my-define-command second-demo
  (list "Protesilaos" "Cyprus")
  (+ 1 1)
  (message "Arbitrary expressions here"))
;; =>
;;
;; (defun modified-version-of-second-demo nil
;;   (interactive)
;;   "The difference between ‘modified-version-of-second-demo’ and ‘second-demo’"
;;   (list "Protesilaos" "Cyprus")
;;   (+ 1 1)
;;   (message "Arbitrary expressions here"))


(my-define-command "error scenario"
  (list "Will" "Not" "Reach" "This")
  (/ 2 0))
;; => ERROR...
#+end_src

Do you need macros? Not always, though there will be cases where a well-defined macro makes your code more elegant. What matters is that you have a sense of how evaluation works so that you do not get confused by all those parentheses. Otherwise you might expect something different to happen than what you actually get.

* Mapping through a list of elements
:PROPERTIES:
:CUSTOM_ID: h:mapping-through-a-list-of-elements
:END:

#+findex: while
#+findex: mapcar
#+findex: mapc
#+findex: dolist
#+findex: seq-filter
#+findex: seq-remove
A common routine in programming is to work through a list of items and perform some computation on each of them. Emacs Lisp has the generic ~while~ loop, as well as a whole range of more specialised functions to map over a list of elements, such as ~mapcar~, ~mapc~, ~dolist~, ~seq-filter~, ~seq-remove~, and many more. Depending on what you are doing, you map through elements with the intent to produce some side effect and/or to test for a return value ([[#h:side-effect-and-return-value][Side effect and return value]]). I will show you some examples and let you decide which is the most appropriate tool for the task at hand.

#+findex: mapcar
#+cindex: Accumulating results of a map
Starting with ~mapcar~, it applies a function to each element of a list. It then takes the return value at each iteration and collects it into a new list. This is the return value of ~mapcar~ as a whole. In the following code block, I use ~mapcar~ over a list of numbers to increment them by =10= and return a new list of the incremented numbers.

#+begin_src emacs-lisp
(mapcar
 (lambda (number)
   (+ 10 number))
 '(1 2 3 4 5))
;; => (11 12 13 14 15)
#+end_src

In the code block above, I am using a ~lambda~, else an anonymous function ([[#h:when-to-use-a-named-function-or-a-lambda-function][When to use a named function or a lambda function]]). Here is the same code, but with an eponymous function, i.e. a named function:

#+begin_src emacs-lisp
(defun my-increment-by-ten (number)
  "Add 10 to NUMBER."
  (+ 10 number))

(mapcar #'my-increment-by-ten '(1 2 3 4 5))
;; => (11 12 13 14 15)
#+end_src

Notice that here we quote the eponymous function ([[#h:symbols-balanced-expressions-and-quoting][Symbols, balanced expressions, and quoting]]).

#+findex: mapcar
#+findex: mapc
#+cindex: Mapping only for side effects
The ~mapcar~ collects the return values into a new list. Sometimes this is useless. Suppose you want to evaluate a function that saves all unsaved buffers which visit a file. In this scenario, you do not care about accumulating the results: you just want the side effect of saving the buffer outright. To this end, you may use ~mapc~, which always returns the list it operated on:

#+begin_src emacs-lisp
(mapc
 (lambda (buffer)
   (when (and (buffer-file-name buffer)
              (buffer-modified-p buffer))
     (save-buffer)))
 (buffer-list))
#+end_src

#+findex: dolist
An alternative to the above is ~dolist~, which is used for side effects but always returns ~nil~:

#+begin_src emacs-lisp
(dolist (buffer (buffer-list))
  (when (and (buffer-file-name buffer)
             (buffer-modified-p buffer))
    (save-buffer)))
#+end_src

You will notice that the ~dolist~ is a macro, so some parts of it seem to behave differently than with basic lists and the evaluation rules that apply to them ([[#h:evaluation-inside-of-a-macro-or-special-form][Evaluation inside of a macro or special form]]). This is a matter of getting used to how the code is expressed.

#+findex: dolist
#+findex: mapc
When to use a ~dolist~ as opposed to a ~mapc~ is a matter of style. If you are using a named function, a ~mapc~ looks cleaner to my eyes. Otherwise a ~dolist~ is easier to read. Here is my approach with some pseudo-code:

#+begin_src emacs-lisp
;; I like this:
(mapc #'NAMED-FUNCTION LIST)

;; I also like a `dolist' instead of a `mapc' with a `lambda':
(dolist (element LIST)
  (OPERATE-ON element))

;; I do not like this:
(mapc
 (lambda (element)
   (OPERATE-ON element))
 LIST)
#+end_src

While ~dolist~ and ~mapc~ are for side effects, you can still employ them in the service of accumulating results, with the help of ~let~ and related forms ([[#h:control-flow-with-if-let-and-friends][Control flow with ~if-let*~ and friends]]). Depending on the specifics, this approach may make more sense than relying on a ~mapcar~. Here is an annotated sketch:

#+begin_src emacs-lisp
;; Start with an empty list of `found-strings'.
(let ((found-strings nil))
  ;; Use `dolist' to test each element of the list '("Protesilaos" 1 2 3 "Cyprus").
  (dolist (element '("Protesilaos" 1 2 3 "Cyprus"))
    ;; If the element is a string, then `push' it to the `found-strings', else skip it.
    (when (stringp element)
      (push element found-strings)))
  ;; Now that we are done with the `dolist', return the new value of `found-strings'.
  found-strings)
;; => ("Cyprus" "Protesilaos")


;; As above but reverse the return value, which makes more sense:
(let ((found-strings nil))
  (dolist (element '("Protesilaos" 1 2 3 "Cyprus"))
    (when (stringp element)
      (push element found-strings)))
  (nreverse found-strings))
;; => ("Protesilaos" "Cyprus")
#+end_src

For completeness, the previous example would have to be done as follows with the use of ~mapcar~:

#+begin_src emacs-lisp
(mapcar
 (lambda (element)
   (when (stringp element)
     element))
 '("Protesilaos" 1 2 3 "Cyprus"))
;; => ("Protesilaos" nil nil nil "Cyprus")


(delq nil
      (mapcar
       (lambda (element)
         (when (stringp element)
           element))
       '("Protesilaos" 1 2 3 "Cyprus")))
;; => ("Protesilaos" "Cyprus")
#+end_src

Because ~mapcar~ happily accumulates all the return values, it returns a list that includes ~nil~. If you wanted that, you would probably not even bother with the ~when~ clause there. The ~delq~ is thus applied to the return value of the ~mapcar~ to delete all the instances of ~nil~. Now compare this busy work to ~seq-filter~:

#+begin_src emacs-lisp
(seq-filter #'stringp '("Protesilaos" 1 2 3 "Cyprus"))
;; => ("Protesilaos" "Cyprus")
#+end_src

The ~seq-filter~ is the best tool when all you need is to test if the element satisfies a predicate function and then return that element. But you cannot return something else. Whereas ~mapcar~ will take any return value without complaints, such as the following:

#+begin_src emacs-lisp
(delq nil
      (mapcar
       (lambda (element)
         (when (stringp element)
           ;; `mapcar' accumulates any return value, so we can change
           ;; the element to generate the results we need.
           (upcase element)))
       '("Protesilaos" 1 2 3 "Cyprus")))
;; => ("PROTESILAOS" "CYPRUS")

(seq-filter
 (lambda (element)
   (when (stringp element)
     ;; `seq-filter' only returns elements that have a non-nil return
     ;; value here, but it returns the elements, not what we return
     ;; here.  In other words, this `lambda' does unnecessary work.
     (upcase element)))
 '("Protesilaos" 1 2 3 "Cyprus"))
;; => ("Protesilaos" "Cyprus")
#+end_src

#+findex: find-library
#+findex: seq-take
#+findex: seq-find
#+findex: seq-union
#+cindex: Visit the source code of a file
#+cindex: Shortdoc for lists and sequences
How you go about mapping over a list of elements will depend on what you are trying to do. There is no one single function that does everything for you. Understand the nuances and you are good to go. Oh, and do look into the built-in ~seq~ library (use {{{kbd(M-x)}}} (~execute-extended-command~), invoke ~find-library~, and then search for ~seq~). You are now looking at the source code of =seq.el=: it defines plenty of functions like ~seq-take~, ~seq-find~, ~seq-union~. Another way is to invoke the command ~shortdoc~ and read about the documentation groups =list= as well as =sequence=.

* The match data of the last search
:PROPERTIES:
:CUSTOM_ID: h:the-match-data-of-the-last-search
:END:

#+findex: match-data
#+findex: match-beginning
#+findex: match-string
#+findex: re-search-forward
#+findex: looking-at
#+findex: string-match
As you work with Emacs Lisp, you will encounter the concept of "match data" and the concomitant functions ~match-data~, ~match-beginning~, ~match-string~, and so on. These refer to the results of the last search, which is typically performed by the functions ~re-search-forward~, ~looking-at~, ~string-match~, and related. Each time you perform a search, the match data gets updated. Be mindful of this common side effect ([[#h:side-effect-and-return-value][Side effect and return value]]). If you forget about it, chances are your code will not do the right thing.

In the following code block, I define a function that performs a search in the current buffer and returns a list of match data without text properties, where relevant ([[#h:text-has-its-own-properties][Text has its own properties]]).

#+begin_src emacs-lisp
(defun my-get-match-data (regexp)
  "Search forward for REGEXP and return its match data, else nil."
  (when (re-search-forward regexp nil t)
    (list
     :beginning (match-beginning 0)
     :end (match-end 0)
     :string (match-string-no-properties 0))))
#+end_src

You may then call it with a string argument, representing an Emacs Lisp regular expression:

#+begin_src emacs-lisp
(my-get-match-data "Protesilaos.*Cyprus")
#+end_src

If the regular expression matches, then you get the match data. Here is some sample text:

#+begin_src fundamental
Protesilaos lives in the mountains of Cyprus.
#+end_src

Place the cursor before that text and use {{{kbd(M-:)}}} (~eval-expression~) to evaluate ~my-get-match-data~ with the regexp I show above. You will get a return value, as intended.

#+findex: save-excursion
#+findex: point
The way ~my-get-match-data~ is written, it does two things: (i) it has the side effect of moving the cursor to the end of the text it found and (ii) it returns a list with the match data I specified. There are many scenaria where you do not want the aforementioned side effect: the cursor should stay where it is. As such, you can wrap your code in a ~save-excursion~ ([[#h:switching-to-another-buffer-window-or-narrowed-state][Switching to another buffer, window, or narrowed state]]): it will do what it must and finally restore the ~point~ ([[#h:run-some-code-or-fall-back-to-some-other-code][Run some code or fall back to some other code]]):

#+begin_src emacs-lisp
(defun my-get-match-data (regexp)
  "Search forward for REGEXP and return its match data, else nil."
  (save-excursion ; we wrap our code in a `save-excursion' to inhibit the side effect
    (when (re-search-forward regexp nil t)
      (list
       :beginning (match-beginning 0)
       :end (match-end 0)
       :string (match-string-no-properties 0)))))
#+end_src

#+findex: save-match-data
#+cindex: Preserve the last match data
If you evaluate this version of ~my-get-match-data~ and then retry the function call I had above, you will notice how you get the expected return value without the side effect of the cursor moving to the end of the matching text. In practice, this is a useful tool that may be combined with ~save-match-data~. Imagine you want to do a search forward inside of another search you are performing, such as to merely test if there is a match for a regular expression in the context, but need to inhibit the modification of the match data you planned to operate on. As such:

#+begin_src emacs-lisp
(defun my-get-match-data-with-extra-check (regexp)
  "Search forward for REGEXP followed by no spaces and return its match data, else nil."
  (save-excursion
    (when (and (re-search-forward regexp nil t)
               (save-match-data (not (looking-at "[\s\t]+"))))
      ;; Return the match data of the first search.  The second one
      ;; which tests for spaces or tabs is just an extra check, but we
      ;; do not want to use its match data, hence the `save-match-data'
      ;; around it.
      (list
       :beginning (match-beginning 0)
       :end (match-end 0)
       :string (match-string-no-properties 0)))))
#+end_src

Evaluate the function ~my-get-match-data-with-extra-check~ and then call with {{{kbd(M-:)}}} (~eval-expression~) to test that it returns a non-~nil~ value with the second example below, but not the first one. This is the expected outcome.

#+begin_src emacs-lisp
(my-get-match-data-with-extra-check "Protesilaos.*Cyprus")
;; => nil


;; Protesilaos, also known as "Prot", lives in the mountains of Cyprus   .

(my-get-match-data-with-extra-check "Protesilaos.*Cyprus")
;; => (:beginning 41988 :end 42032 :string "Protesilaos lives in the mountains of Cyprus")


;; Protesilaos lives in the mountains of Cyprus.
#+end_src

* Switching to another buffer, window, or narrowed state
:PROPERTIES:
:CUSTOM_ID: h:switching-to-another-buffer-window-or-narrowed-state
:END:

As you use Emacs Lisp to do things programmatically, you encounter cases where you need to move away from where you are. You may have to switch to another buffer, change to the window of a given buffer, or even modify what is visible in the buffer you are editing. At all times, this involves one or more side effects which, most probably, should be undone when your function finishes its job ([[#h:side-effect-and-return-value][Side effect and return value]]).

#+findex: point
#+findex: save-excursion
#+cindex: Restore the point
Perhaps the most common case is to restore the ~point~. You have some code that moves back or forth in the buffer to perform a match for a given piece of text. But then, you need to leave the cursor where it originally was, otherwise the user will lose their orientation. Wrap your code in a ~save-excursion~ and you are good to go, as I show elsewhere ([[#h:the-match-data-of-the-last-search][The match data of the last search]]):

#+begin_src emacs-lisp
(save-excursion ; restore the `point' after you are done
  MOVE-AROUND-IN-THIS-BUFFER)
#+end_src

#+findex: save-window-excursion
#+findex: select-window
#+cindex: Restore the selected window
Same principle for ~save-window-excursion~, which allows you to select another window, such as with ~select-window~, move around in its buffer, and then restore the windows as they were:

#+begin_src emacs-lisp
(save-window-excursion
  (select-window SOME-WINDOW)
  MOVE-AROUND-IN-THIS-BUFFER)
#+end_src

#+findex: save-restriction
#+findex: widen
#+findex: narrow-to-region
#+findex: org-narrow-to-subtree
#+cindex: Restore the narrowing state
The ~save-restriction~ allows you to restore the current narrowing state of the buffer. You may then choose to either ~widen~ or ~narrow-to-region~ (and related commands like ~org-narrow-to-subtree~), do what you must, and then restore the buffer to its original state.

#+begin_src emacs-lisp
;; Here we assume that we start in a widened state.  Then we narrow to
;; the current Org heading to get all of its contents as one massive
;; string.  Then we widen again, courtesy of `save-restriction'.
(save-restriction
  (org-narrow-to-subtree)
  (buffer-string))
#+end_src

Depending on the specifics, you will want to combine the aforementioned. Beware that the documentation of ~save-restriction~ tells you to use ~save-excursion~ as the outermost call. Other than that, you will also find cases that require a different approach to perform some conditional behaviour ([[#h:run-some-code-or-fall-back-to-some-other-code][Run some code or fall back to some other code]]).

* Basic control flow with ~if~, ~cond~, and others
:PROPERTIES:
:CUSTOM_ID: h:basic-control-flow-with-if-cond-and-others
:END:

#+findex: defun
#+findex: forward-line
You do not need any conditional logic to perform basic operations. For example, if you write a command that moves 15 lines down, it will naturally stop at the end of the buffer when it cannot move past the number you specified. Using ~defun~, you write an interactive function (i.e. a "command") to unconditionally move down 15 lines using ~forward-line~ internally (call it with a negative number to move in the opposite direction):

#+begin_src emacs-lisp
(defun my-15-lines-down ()
  "Move at most 15 lines down."
  (interactive)
  (forward-line 15))
#+end_src

#+findex: if
#+findex: when
#+findex: unless
#+findex: cond
#+findex: and
#+findex: or
#+cindex: Control flow
The ~my-15-lines-down~ is about as simple as it gets: it wraps around a basic function and passes to it a fixed argument, in this case the number =15=. Use {{{kbd(M-x)}}} (~execute-extended-command~) and then call this command by its name. It works! Things get more involved as soon as you decide to perform certain actions only once a given condition is met. This "control flow" between different branches of a logical sequence is expressed with ~if~, ~when~, ~unless~, and ~cond~, among others. Depending on the specifics of the case, ~and~ as well as ~or~ may suffice.

#+findex: eobp
#+findex: string-match-p
#+findex: stringp
#+cindex: Predicate functions
How about you make your ~my-15-lines-down~ a bit smarter? When it is at the absolute end of the buffer, have it move 15 lines up. Why? Because this is a demonstration, so why not? The predicate function that tests if the point is at the end of the buffer is ~eobp~. A "predicate" is a function that returns true, technically non-~nil~, when its condition is met, else it returns ~nil~ ([[#h:side-effect-and-return-value][Side effect and return value]]). As for the weird name, the convention in Emacs Lisp is to end predicate functions with the =p= suffix: if the name of the function consists of multiple words, typically separated by dashes, then the predicate function is named =NAME-p=, like ~string-match-p~, otherwise it is =NAMEp=, like ~stringp~.

#+begin_src emacs-lisp
(defun my-15-lines-down-or-up ()
  "Move at most 15 lines down or go back if `eobp' is non-nil."
  (interactive)
  (if (eobp)
      (forward-line -15)
    (forward-line 15)))
#+end_src

Evaluate this function, then type {{{kbd(M-x)}}} (~execute-extended-command~) and invoke ~my-15-lines-down-or-up~ to get a feel for it. Below is a similar idea, which throws and error and exits what it was doing if ~eobp~ returns non-~nil~:

#+begin_src emacs-lisp
(defun my-15-lines-down-or-error ()
  "Throw an error if `eobp' returns non-nil, else move 15 lines down."
  (interactive)
  (if (eobp)
      (error "Already at the end; will not move further")
    (forward-line 15)))
#+end_src

#+cindex: Indentation in Emacs Lisp
A quirk of Emacs Lisp, which may be a feature all along, is how indentation is done. Just mark the code you have written and type {{{kbd(TAB)}}}: Emacs will take care to indent it the way it should be done. In the case of the ~if~ statement, the "then" part is further in than the "else" part of the logic. There is no special meaning to this indentation: you could write everything on a single line like =(if COND THIS ELSE)=, which looks like your typical list, by the way ([[#h:symbols-balanced-expressions-and-quoting][Symbols, balanced expressions, and quoting]]). What the indentation does is help you identify imbalances in your parentheses. If the different expressions all line up in a way that looks odd, then you are most probably missing a parentheses or have too many of them. Generally, expressions at the same level will all line up the same way. Those deeper in will have more indentation, and so on. Experience will allow you to spot mistakes with mismatching parentheses. But even if you do not identify them, you will get an error eventually. Rest assured!

The way ~if~ is written is like a function that takes two or more arguments. The "or more" all counts as part of the "else" logic. As such, =(if COND THIS)= has no "else" consequence, while =(if COND THIS ELSE1 ELSE2 ELSE3)= will run =ELSE1=, =ELSE2=, and =ELSE3= in order as part of the "else" branch. Here is how this looks once you factor in proper indentation:

#+begin_src emacs-lisp
(if COND
    THIS
  ELSE1
  ELSE2
  ELSE3)
#+end_src

#+findex: progn
Now what if the =THIS= part needs to be more than one function call? Elisp has the ~progn~ form, which you can use to wrap function calls and pass them as a single argument. Putting it all together, your code will now look this like:

#+begin_src emacs-lisp
(if COND
    (progn
      THIS1
      THIS2
      THIS3)
  ELSE1
  ELSE2
  ELSE3)
#+end_src

#+findex: when
If you do not need the "else" part, use ~when~ to express your intention. Internally, this is a macro which actually stands for =(if COND (progn EXPRESSIONS))=, where =EXPRESSIONS= is one or more expressions. A ~when~ looks like this:

#+begin_src emacs-lisp
(when COND
  THIS1
  THIS2
  THIS3)
#+end_src

#+findex: unless
Similarly, the ~unless~ has the meaning of =(when (not COND) EXPRESSIONS)=. It, too, is a macro that expands to an ~if~ statement:

#+begin_src emacs-lisp
(unless COND
  THIS1
  THIS2
  THIS3)
#+end_src

#+findex: and
#+findex: or
When the condition you are testing for has multiple parts, you can rely on ~and~ as well as ~or~:

#+begin_src emacs-lisp
(when (or THIS THAT)
  EXPRESSIONS)

(when (and THIS THAT)
  EXPRESSIONS)

(when (or (and THIS THAT) OTHER)
  EXPRESSIONS)
#+end_src

#+findex: if
#+findex: when
#+findex: or
#+findex: and
#+findex: cond
Depending on the specifics of the case, the combination of multiple ~if~, ~when~, ~or~, ~and~ will look awkward. You can break down the logic to distinct conditions, which are tested in order from top to bottom, using ~cond~. The way ~cond~ is written is as a list of lists, which do not need quoting ([[#h:evaluation-inside-of-a-macro-or-special-form][Evaluation inside of a macro or special form]]). In abstract, it looks like this:

#+begin_src emacs-lisp
(cond
 (CONDITION1
  CONSEQUENCES1)
 (CONDITION2
  CONSEQUENCES2)
 (CONDITION3
  CONSEQUENCES3)
 (t
  CONSEQUENCES-FALLBACK))
#+end_src

Each of the consequences can be any number of expressions, like you saw above with ~when~. This is a toy function to show how ~cond~ behaves:

#+begin_src emacs-lisp
(defun my-toy-cond (argument)
  "Return a response depending on the type of ARGUMENT."
  (cond
   ((and (stringp argument)
         (string-blank-p argument))
    (message "You just gave me a blank string; try harder!"))
   ((stringp argument)
    (message "I see you can do non-blanks string; I call that progress."))
   ((null argument)
    (message "Yes, the nil is an empty list like (), but do not worry about it"))
   ((listp argument)
    (message "Oh, I see you are in the flow of using lists!"))
   ((symbolp argument)
    (message "What's up with the symbols, mate?"))
   ((natnump argument)
    (message "I fancy those natural numbers!"))
   ((numberp argument)
    (message "You might as well be a math prodigy!"))
   (t
    (message "I have no idea what type of thing your argument `%s' is" argument))))
#+end_src

I want you to evaluate it and pass it different arguments to test what it does ([[#h:evaluate-emacs-lisp][Evaluate Emacs Lisp]]). Here are two examples:

#+begin_src emacs-lisp
(my-toy-cond "")
;; => "You just gave me a blank string; try harder!"

(my-toy-cond '(1 2 3))
;; => "Oh, I see you are in the flow of using lists!"
#+end_src

All of the above are common in Emacs Lisp. Another powerful macro is ~pcase~, which we will consider separately due to its particularities ([[#h:pattern-match-with-pcase-and-related][Pattern match with ~pcase~ and related]]).

* Control flow with ~if-let*~ and friends
:PROPERTIES:
:CUSTOM_ID: h:control-flow-with-if-let-and-friends
:END:

#+findex: let
#+findex: let*
#+cindex: Let bind variables in the current scope
The ~let~ and ~let*~ declare variables that are available only within the current scope, else the =BODY= of the ~let~. As such:

#+begin_src emacs-lisp
(let BINDINGS
  BODY)

(let ((variable1 value1)
      (variable2 value2))
  BODY)
#+end_src

The =BINDINGS= is a list of lists, which does not need to be quoted ([[#h:evaluation-inside-of-a-macro-or-special-form][Evaluation inside of a macro or special form]]). While =BODY= consists of one or more expressions, which I have also named =EXPRESSIONS= elsewhere in this book. The difference between ~let~ and ~let*~ (pronounced "let star") is that the latter makes earlier bindings available to later bindings. Like this:

#+begin_src emacs-lisp
;; This works because `greeting' can access `name' and `country',
;; courtesy of `let*':
(let* ((name "Protesilaos")
       (country "Cyprus")
       (greeting (format "Hello %s of %s" name country)))
  (DO-STUFF-WITH greeting))

;; But this fails...
(let ((name "Protesilaos")
      (country "Cyprus")
      (greeting (format "Hello %s of %s" name country)))
  (DO-STUFF-WITH greeting))
#+end_src

Sometimes what you want to do is create those bindings if---and only if---they are all non-~nil~. If their value is ~nil~, then they are useless to you, in which case you do something else ([[#h:basic-control-flow-with-if-cond-and-others][Basic control flow with ~if~, ~cond~, and others]]). Values may or may not be ~nil~ when you are creating a binding with the return value of a function call or some other variable. You could always write code like this:

#+begin_src emacs-lisp
(let ((variable1 (SOME-FUNCTION SOME-ARGUMENT))
      (variable2 (OTHER-FUNCTION OTHER-ARGUMENT)))
  (if (and variable1 variable2) ; simply test both for non-nil
      THIS
    ELSE))
#+end_src

#+findex: if-let*
But you can do the same with ~if-let*~, where the =THIS= part runs only if all the bindings are non-~nil~:

#+begin_src emacs-lisp
(if-let* ((variable1 (SOME-FUNCTION SOME-ARGUMENT))
          (variable2 (OTHER-FUNCTION OTHER-ARGUMENT)))
    THIS
  ELSE)
#+end_src

In the =ELSE= part, the bindings ~variable1~ and ~variable2~ do not exist: they only exist for the =THIS= part of the code.

#+findex: when-let*
The ~when-let*~ is the same as ~when~, meaning that it has no "else" logic. If one of its bindings is ~nil~, then the whole ~when-let*~ returns ~nil~. No need to belabour that point.

As you dig dipper into the Emacs Lisp ecosystem, you will come across uses of ~if-let*~ that (i) create multiple bindings like ~let~ or ~let*~ but (ii) also call a predicate function to test if they should continue with the =THIS= part of their logic. Remember that ~if-let*~ goes straight to =ELSE= if one of its bindings returns ~nil~. Consider this example:

#+begin_src emacs-lisp
(if-let* ((variable1 (SOME-FUNCTION SOME-ARGUMENT))
          ;; The _ signifies intent: "do not bind this; I only care
          ;; about the return value being non-nil".  What we are doing
          ;; here is test if `variable1' is a string: if it is, we
          ;; continue with the bindings, otherwise we move to the ELSE
          ;; part of the code.
          (_ (string-match-p variable1))
          (variable2 (OTHER-FUNCTION OTHER-ARGUMENT)))
    THIS
  ELSE)
#+end_src

There is no inherently superior way of doing things. It is a matter of using the right tool for the task at hand. Sometimes you want the bindings to be created, even if their value is ~nil~. Choose what makes sense.

* Pattern match with ~pcase~ and related
:PROPERTIES:
:CUSTOM_ID: h:pattern-match-with-pcase-and-related
:END:

#+findex: pcase
#+vindex: major-mode
Once you get in the flow of expressing your thoughts with Emacs Lisp, you will be fluent in the use of ~if~, ~cond~, and the like ([[#h:basic-control-flow-with-if-cond-and-others][Basic control flow with ~if~, ~cond~, and others]]). You might even get more fancy if ~if-let*~ ([[#h:control-flow-with-if-let-and-friends][Control flow with ~if-let*~ and friends]]). However you go about it, there are some cases that arguably benefit from more succinct expressions. This is where ~pcase~ comes in. At its more basic formulation, it is like ~cond~, in that it tests the return value of a given expression against a list of conditions. Here is an example that compared the buffer-local value of the variable ~major-mode~ for equality against a couple of known symbols:

#+begin_src emacs-lisp
(pcase major-mode
  ('org-mode (message "You are in Org"))
  ('emacs-lisp-mode (message "You are in Emacs Lisp"))
  (_ (message "You are somewhere else")))
#+end_src

The above is the same idea as this ~cond~:

#+begin_src emacs-lisp
(cond
 ((eq major-mode 'org-mode)
  (message "You are in Org"))
 ((eq major-mode 'emacs-lisp-mode)
  (message "You are in Emacs Lisp"))
 (t
  (message "You are somewhere else")))
#+end_src

#+findex: pcase
#+findex: message
Some programmers may argue that ~pcase~ is more elegant. I think it is true in this specific example, though I remain flexible and practical: I will use whatever makes more sense for the code I am writing. While on the topic of elegance, I should inform you that practically all of the conditional logic can be done in a way that may seem unexpected. Consider how my examples in this book make repetitive use of ~message~, when in reality the only part that changes is the actual string/argument passed to that function. This will work just as well:

#+begin_src emacs-lisp
(message
 (pcase major-mode
   ('org-mode "You are in Org")
   ('emacs-lisp-mode "You are in Emacs Lisp")
   (_ "You are somewhere else")))
#+end_src

Same idea for ~if~, ~when~, and the rest.

#+cindex: Domain-Specific Language (DSL)
Back to the topic of what ~pcase~ does differently. If you read its documentation, you will realise that it has its own mini language, or "domain-specific language" (DSL). This is common for macros ([[#h:evaluation-inside-of-a-macro-or-special-form][Evaluation inside of a macro or special form]]). They define how evaluation is done and what sort of expressions are treated specially. Let me then gift you this toy function that illustrates some of the main features of the DSL now under consideration:

#+begin_src emacs-lisp
(defun my-toy-pcase (argument)
  "Use `pcase' to return an appropriate response for ARGUMENT."
  (pcase argument
    (`(,one ,_ ,three)
     (message "List where first element is `%s', second is ignored, third is `%s'" one three))
    (`(,one . ,two)
     (message "Cons cell where first element is `%s' and second is `%s'" one two))
    ((pred stringp)
     (message "The argument is a string of some sort"))
    ('hello
     (message "The argument is equal to the symbol `hello'"))
    (_ (message "This is the fallback"))))
#+end_src

Go ahead and evaluate that function and then try it out ([[#h:evaluate-emacs-lisp][Evaluate Emacs Lisp]]). Below are a couple of examples:

#+begin_src emacs-lisp
(my-toy-pcase '("Protesilaos" "of" "Cyprus"))
;; => "List where first element is ‘Protesilaos’, second is ignored, third is ‘Cyprus’"

(my-toy-pcase '("Protesilaos" . "Cyprus"))
;; => "Cons cell where first element is ‘Protesilaos’ and second is ‘Cyprus’"
#+end_src

#+findex: pcase-let
#+findex: pcase-let*
#+findex: pcase-lambda
#+findex: pcase-dolist
#+findex: let
#+findex: let*
#+findex: lambda
#+findex: dolist
#+cindex: Destructuring
Some of those clauses are a different way to express ~cond~. Arguably better, but not a clear winner in my opinion. What is impressive and a true paradigm shift is the concept of "destructuring", else the pattern matching done to the expression that effectively ~let~ binds elements of a list or cons cell to their corresponding index. The syntax used for this destructuring is arcane, until you relate it to the quasi-quote and the comma which are used for partial evaluation ([[#h:partial-evaluation-inside-of-a-list][Partial evaluation inside of a list]]). With this in mind, consider ~pcase-let~, ~pcase-let*~, ~pcase-lambda~, and ~pcase-dolist~, as variations of the plain ~let~, ~let*~, ~lambda~, and ~dolist~ with the added feature of supporting destructuring. They are not doing any of the extras of ~pcase~ though---just destructuring on top of their familiar behaviour! This is especially useful when you are working with the return value of a function which comes as a list. I will not elaborate at length, as this is an advanced use-case. If you are already at that level, you do not need me to tell you what to write. For the rest of us who, like me, typically work with simpler code, the ~pcase-let~ serves as a sufficient illustration of the principle:

#+begin_src emacs-lisp
(defun my-split-string-at-space (string)
  "Split STRING at the space, returning a list of strings."
  (split-string string "\s"))

(pcase-let ((`(,one ,_ ,three) (my-split-string-at-space "Protesilaos of Cyprus")))
  (message "This is like `let', but we got `%s' and `%s' via destructuring" one three))
;; => "This is like ‘let’, but we got ‘Protesilaos’ and ‘Cyprus’ via destructuring"
#+end_src

Whether you use ~pcase~ and destructuring in general is up to you. You do not require them to write high quality code. Though you might agree with those who consider them inherently more elegant and opt to use them for this very reason to have code that is succinct yet highly expressive.

* Run some code or fall back to some other code
:PROPERTIES:
:CUSTOM_ID: h:run-some-code-or-fall-back-to-some-other-code
:END:

#+findex: unwind-protect
#+cindex: Unwinding
Your typical code will rely on ~if~, ~cond~, and the like for control flow ([[#h:basic-control-flow-with-if-cond-and-others][Basic control flow with ~if~, ~cond~, and others]]). Depending on your specific needs or stylistic considerations, it may even include ~pcase~ ([[#h:pattern-match-with-pcase-and-related][Pattern match with ~pcase~ and related]]) as well as ~if-let*~ ([[#h:control-flow-with-if-let-and-friends][Control flow with ~if-let*~ and friends]]). There are some cases, nonetheless, that make it imperative you run additional code after your primary operation concludes or exits. The idea is to clean up whatever intermediate state you created. The logic is "do this with all the necessary side effects, then whatever happens to it do that now to, inter alia, undo the side effects." This is the concept of "unwinding", which is implemented via ~unwind-protect~.

#+findex: y-or-n-p
In the following code block, I define a function which produces a minibuffer prompt asking you to provide a =y= or =n= answer, which is shorthand notation for "yes" or "no". It tests the return value of ~y-or-n-p~ to determine what it needs to do. While the prompt is open, the function highlights all instances of the regular expression =(defun= in the current buffer. Those highlights must go away after you are done with the minibuffer and its consequences.

#+begin_src emacs-lisp
(defun my-prompt-with-temporary-highlight ()
  "Ask for confirmation and highlight all instances of a regexp while waiting."
  (let ((regexp "(defun"))
    (unwind-protect
        (progn
          (highlight-regexp regexp)
          (if (y-or-n-p "Should we proceed or not? ")
              (message "You have decided to proceed")
            (message "You prefer not to continue")))
      (unhighlight-regexp regexp))))
#+end_src

Try the above in your Emacs to get a feel for it. While the "yes or no" prompt is active, also do {{{kbd(C-g)}}} (~keyboard-quit~) or {{{kbd(C-])}}} (~abort-recursive-edit~) to confirm that the highlights are removed even though the code never gets past the prompting phase. You may even modify the function to produce an error: it will create a backtrace, which will still have the effect of unwinding after you do {{{kbd(q)}}} (~debugger-quit~) from the =*Backtrace*= window.

#+begin_src emacs-lisp
(defun my-prompt-with-temporary-highlight-try-with-error ()
  "Ask for confirmation and highlight all instances of a regexp while waiting."
  (let ((regexp "(defun"))
    (unwind-protect
        (progn
          (highlight-regexp regexp)
          (error "This error makes no sense here; close the backtrace to test the unwinding")
          (if (y-or-n-p "Should we proceed or not? ")
              (message "You have decided to proceed")
            (message "You prefer not to continue")))
      (unhighlight-regexp regexp))))
#+end_src

#+findex: unwind-protect
#+findex: save-excursion
#+findex: save-restriction
#+findex: save-match-data
#+findex: with-temp-buffer
#+findex: save-window-excursion
#+findex: error
Taking a step back, you will figure out how ~unwind-protect~ is a more general form of specialists like ~save-excursion~ and ~save-restriction~ ([[#h:switching-to-another-buffer-window-or-narrowed-state][Switching to another buffer, window, or narrowed state]]), while it underpins the ~save-match-data~ ([[#h:the-match-data-of-the-last-search][The match data of the last search]]) among many other functions/macros, such as ~with-temp-buffer~ and ~save-window-excursion~. What ~unwind-protect~ does not do is respond specially to signals, such as those coming from the ~error~ function: it will allow the error to happen, meaning that a backtrace will be displayed and your code will exit right there (but the unwinding will still work, as I already explained, once you dismiss the backtrace). To make your code treat signals in a more controlled fashion, you must rely on ~condition-case~.

#+findex: condition-case
#+cindex: Catching errors and other signals
#+cindex: Non-local exits
#+findex: signal
With ~condition-case~ you assume full control over the behaviour of your code, including how it should deal with errors. Put differently, your Elisp will express the intent of "I want to do this, but if I get an error I want to do that instead." There are many signals to consider, all of which come from the ~signal~ function. These include the symbols ~error~, ~user-error~, ~args-out-of-range~, ~wrong-type-argument~, ~wrong-length-argument~, and ~quit~, in addition to anything else the programmer may consider necessary. In the following code blocks, I show you how ~condition-case~ looks like. Remember that sometimes you do not do quoting the usual way because of how the underlying form is implemented ([[#h:evaluation-inside-of-a-macro-or-special-form][Evaluation inside of a macro or special form]]). The example I am using is the same I had for ~unwind-protect~.

#+begin_src emacs-lisp
(defun my-prompt-with-temporary-highlight-and-signal-checks ()
  "Ask for confirmation and highlight all instances of a regexp while waiting."
  (let ((regexp "(defun"))
    (condition-case nil
        (progn
          (highlight-regexp regexp)
          (if (y-or-n-p "Should we proceed or not? ")
              (user-error "You have decided to proceed; but we need to return a `user-error'")
            (error "You prefer not to continue; but we need to return an `error'")))
      (:success
       (unhighlight-regexp regexp)
       (message "No errors, but still need to unwind what we did, plus whatever else we want here"))
      (quit
       (unhighlight-regexp regexp)
       (message "This is our response to the user aborting the prompt"))
      (user-error
       (unhighlight-regexp regexp)
       (message "This is our response to the `user-error' signal"))
      (error
       (unhighlight-regexp regexp)
       (message "This is our response to the `error' signal")))))
#+end_src

#+findex: condition-case
#+findex: let
#+findex: unwind-protect
#+findex: cond
#+findex: message
#+findex: user-error
The above function illustrates both the aforementioned concept of unwinding and the mechanics of handling signals. The abstract structure of ~condition-case~ looks to me like an amalgamation of ~let~, ~unwind-protect~, and ~cond~. These conditions may include the special handler of =:success=, as I show there. Granted, the code I wrote will never lead to that specific success case, though you can modify what happens after the prompt to, say, call ~message~ instead of the ~user-error~ function, which will then count as a successful conclusion. Otherwise, I think the expressions I wrote tell you exactly how this program responds to the signals it receives.

What I have not covered yet, is the aspect of ~condition-case~ that is like the ~let~, namely, how it binds the error data to a variable within this scope. In my implementation above, it is the ~nil~ you see there, meaning that I choose not to perform such a binding, as I have no use for its data. Below I decide to use it, just for the sake of demonstration.

#+begin_src emacs-lisp
(defun my-prompt-with-temporary-highlight-and-signal-checks-with-error-report ()
  "Ask for confirmation and highlight all instances of a regexp while waiting."
  (let ((regexp "(defun"))
    (condition-case error-data-i-got
        (progn
          (highlight-regexp regexp)
          (if (y-or-n-p "Should we proceed or not? ")
              (user-error "You have decided to proceed; but we need to return a `user-error'")
            (error "You prefer not to continue; but we need to return an `error'")))
      (:success
       (unhighlight-regexp regexp)
       (message "No errors, but still need to unwind what we did, plus whatever else we want here")
       (message "The error is `%s' and its data is `%S'" (car error-data-i-got) (cdr error-data-i-got)))
      (quit
       (unhighlight-regexp regexp)
       (message "This is our response to the user aborting the prompt")
       (message "The error is `%s' and its data is `%S'" (car error-data-i-got) (cdr error-data-i-got)))
      (user-error
       (unhighlight-regexp regexp)
       (message "This is our response to the `user-error' signal")
       (message "The error is `%s' and its data is `%S'" (car error-data-i-got) (cdr error-data-i-got)))
      (error
       (unhighlight-regexp regexp)
       (message "This is our response to the `error' signal")
       (message "The error is `%s' and its data is `%S'" (car error-data-i-got) (cdr error-data-i-got))))))
#+end_src

There will be times when ~unwind-protect~ and ~condition-case~ are the right tools for the job. My hope is that these examples have given you the big picture view and you are now ready to write your own programs in Emacs Lisp.

* When to use a named function or a lambda function
:PROPERTIES:
:CUSTOM_ID: h:when-to-use-a-named-function-or-a-lambda-function
:END:

#+findex: lambda
#+cindex: Anonymous and eponymous functions
The ~lambda~ is an anonymous function. It stands in juxtaposition to ~defun~, which defines a function with a given name. When to use one or the other is largely a matter of style. Though there are some cases where a certain approach is more appropriate. The rule of thumb is this: if you need to use the function more than once, then give it a name and then call it by its name. Otherwise, you will effectively be redefining it each time, which makes it hard for you to rewrite your program. By contrast, if the function is only relevant ad-hoc, then a ~lambda~ is fine.

In some cases, you will have a named function that employs a ~lambda~ internally. To modify one of the examples you will find in this book ([[#h:mapping-through-a-list-of-elements][Mapping through a list of elements]]):

#+begin_src emacs-lisp
(defun my-increment-numbers-by-ten (numbers)
  "Add 10 to each number in NUMBERS and return the new list."
  (mapcar
   (lambda (number)
     (+ 10 number))
   numbers))

(my-increment-numbers-by-ten '(1 2 3))
;; => (11 12 13)
#+end_src

A ~lambda~ inside of a named function may also be used to do something over and over again, with the help of ~let~. You may, for instance, have a function that needs to greet a list of people as a side effect with ~mapc~ and you do not want to define the same function more than once:

#+begin_src emacs-lisp
(defun my-greet-teams (&rest teams)
  "Say hello to each person in TEAMS and return list with all persons per team.
Each member of TEAMS is a list of strings."
  (let* ((greet-name (lambda (name)
                       (message "Hello %s" name)))
         (greet-team-and-names (lambda (team)
                                 (message "Greeting the team of `%s'..." team)
                                 (mapc greet-name team))))
    (mapcar greet-team-and-names teams)))

(my-greet-teams
 '("Pelé" "Ronaldo")
 '("Maradona" "Messi")
 '("Beckenbauer" "Neuer")
 '("Platini" "Zidane")
 '("Baresi" "Maldini")
 '("Eusebio" "Cristiano Ronaldo")
 '("Xavi" "Iniesta")
 '("Charlton" "Shearer")
 '("Puskas" "Kubala")
 '("All of the Greece Euro 2004 squad ;)"))
;; => (("Pelé" "Ronaldo") ("Maradona" "Messi") ...)
#+end_src

#+cindex: View the echo area messages
The greetings are a side effect in this case and are available in the =*Messages*= buffer. You can quickly access that buffer with {{{kbd(C-h e)}}} (~view-echo-area-messages~). It does not really matter what ~my-greet-teams~ is doing. Focus on the combination of a named function and anonymous functions inside of it.

* Make your interactive function also work from Lisp calls
:PROPERTIES:
:CUSTOM_ID: h:make-your-interactive-function-also-work-from-lisp-calls
:END:

#+findex: interactive
#+findex: read-string
#+cindex: Interactive functions are commands
#+cinfex: The interactive specification
Functions can be used interactively when they are declared with the ~interactive~ specification. This turns them into "commands". They can be called via their name by first doing {{{kbd(M-x)}}} (~execute-extended-command~) and then finding the command. They may also be assigned to a key and invoked directly by pressing that key. In its simplest form, the ~interactive~ specification is an unquoted list like ~(interactive)~. Here is a trivial example that calls ~read-string~ to produce a minibuffer prompt which accepts user input and returns it as a string:

#+begin_src emacs-lisp
(defun my-greet-person ()
  (interactive)
  (message "Hello %s" (read-string "Whom to greet? ")))
#+end_src

The problem with the above implementation is that it is only useful in interactive use. If you want to issue such a greeting non-interactively through a program, you need to write another function that does practically the same thing except that it takes a =NAME= argument. Like this:

#+begin_src emacs-lisp
(defun my-greet-person-with-name (name)
  "Greet person with NAME."
  (message "Hello %s" name))
#+end_src

You do not need to write two separate functions which practically do the same thing. Instead, you can have one function, with its parameters, which decides how to get the values of the arguments passed to it depending on if it is called interactively or programmatically. Consider this scenario:

#+begin_src emacs-lisp
(defun my-greet-interactive-and-non-interactive (name)
  "Greet person with NAME.
When called interactively, produce a minibuffer prompt asking for NAME.

When called from Lisp, NAME is a string."
  (interactive (list (read-string "Whom to greet? ")))
  (message "Hello %s" name))
#+end_src

#+findex: defun
The documentation I wrote there tells you exactly what is happening. Though let me explain ~interactive~ in further detail: it takes an argument, which is a list that corresponds to the argument list of the current ~defun~. In this case, the ~defun~ has a list of arguments that includes a single element, the =NAME=. Thus, ~interactive~ also has a list with one element, whose value corresponds to =NAME=. If the parameters were more than one, then the ~interactive~ would have to be written accordingly: each of its elements would correspond to the parameter at the same index on the list.

This list of expressions you pass to ~interactive~ essentially is the preparatory work that binds values to the parameters. When you call the above function interactively, you practically tell Emacs that in this case =NAME= is the return value of the call to ~read-string~. For more parameters, you get the same principle but I write it down just to be clear:

#+begin_src emacs-lisp
(defun my-greet-with-two-parameters (name country)
  "Greet person with NAME from COUNTRY.
When called interactively, produce a minibuffer prompt asking for NAME
and then another prompt for COUNTRY.

When called from Lisp, NAME and COUNTRY are strings."
  (interactive
   (list
    (read-string "Whom to greet? ")
    (read-string "Where from? ")))
  (message "Hello %s of %s" name country))

(my-greet-with-two-parameters "Protesilaos" "Cyprus")
;; => "Hello Protesilaos of Cyprus"
#+end_src

Write ~interactive~ specifications with care and you will end up with a rich corpus of code that is economical and flexible.

* COPYING
:PROPERTIES:
:COPYING: t
:CUSTOM_ID: h:copying
:END:

Copyright (C) 2025 Protesilaos Stavrou

#+begin_quote
Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3 or
any later version published by the Free Software Foundation; with no
Invariant Sections, with the Front-Cover Texts being “A GNU Manual,” and
with the Back-Cover Texts as in (a) below.  A copy of the license is
included in the section entitled “GNU Free Documentation License.”

(a) The FSF’s Back-Cover Text is: “You have the freedom to copy and
modify this GNU manual.”
#+end_quote

* GNU Free Documentation License
:PROPERTIES:
:APPENDIX: t
:CUSTOM_ID: h:gnu-free-documentation-license
:END:

#+texinfo: @include doclicense.texi

#+begin_export html
<pre>

                GNU Free Documentation License
                 Version 1.3, 3 November 2008


 Copyright (C) 2000, 2001, 2002, 2007, 2008 Free Software Foundation, Inc.
     <https://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

0. PREAMBLE

The purpose of this License is to make a manual, textbook, or other
functional and useful document "free" in the sense of freedom: to
assure everyone the effective freedom to copy and redistribute it,
with or without modifying it, either commercially or noncommercially.
Secondarily, this License preserves for the author and publisher a way
to get credit for their work, while not being considered responsible
for modifications made by others.

This License is a kind of "copyleft", which means that derivative
works of the document must themselves be free in the same sense.  It
complements the GNU General Public License, which is a copyleft
license designed for free software.

We have designed this License in order to use it for manuals for free
software, because free software needs free documentation: a free
program should come with manuals providing the same freedoms that the
software does.  But this License is not limited to software manuals;
it can be used for any textual work, regardless of subject matter or
whether it is published as a printed book.  We recommend this License
principally for works whose purpose is instruction or reference.


1. APPLICABILITY AND DEFINITIONS

This License applies to any manual or other work, in any medium, that
contains a notice placed by the copyright holder saying it can be
distributed under the terms of this License.  Such a notice grants a
world-wide, royalty-free license, unlimited in duration, to use that
work under the conditions stated herein.  The "Document", below,
refers to any such manual or work.  Any member of the public is a
licensee, and is addressed as "you".  You accept the license if you
copy, modify or distribute the work in a way requiring permission
under copyright law.

A "Modified Version" of the Document means any work containing the
Document or a portion of it, either copied verbatim, or with
modifications and/or translated into another language.

A "Secondary Section" is a named appendix or a front-matter section of
the Document that deals exclusively with the relationship of the
publishers or authors of the Document to the Document's overall
subject (or to related matters) and contains nothing that could fall
directly within that overall subject.  (Thus, if the Document is in
part a textbook of mathematics, a Secondary Section may not explain
any mathematics.)  The relationship could be a matter of historical
connection with the subject or with related matters, or of legal,
commercial, philosophical, ethical or political position regarding
them.

The "Invariant Sections" are certain Secondary Sections whose titles
are designated, as being those of Invariant Sections, in the notice
that says that the Document is released under this License.  If a
section does not fit the above definition of Secondary then it is not
allowed to be designated as Invariant.  The Document may contain zero
Invariant Sections.  If the Document does not identify any Invariant
Sections then there are none.

The "Cover Texts" are certain short passages of text that are listed,
as Front-Cover Texts or Back-Cover Texts, in the notice that says that
the Document is released under this License.  A Front-Cover Text may
be at most 5 words, and a Back-Cover Text may be at most 25 words.

A "Transparent" copy of the Document means a machine-readable copy,
represented in a format whose specification is available to the
general public, that is suitable for revising the document
straightforwardly with generic text editors or (for images composed of
pixels) generic paint programs or (for drawings) some widely available
drawing editor, and that is suitable for input to text formatters or
for automatic translation to a variety of formats suitable for input
to text formatters.  A copy made in an otherwise Transparent file
format whose markup, or absence of markup, has been arranged to thwart
or discourage subsequent modification by readers is not Transparent.
An image format is not Transparent if used for any substantial amount
of text.  A copy that is not "Transparent" is called "Opaque".

Examples of suitable formats for Transparent copies include plain
ASCII without markup, Texinfo input format, LaTeX input format, SGML
or XML using a publicly available DTD, and standard-conforming simple
HTML, PostScript or PDF designed for human modification.  Examples of
transparent image formats include PNG, XCF and JPG.  Opaque formats
include proprietary formats that can be read and edited only by
proprietary word processors, SGML or XML for which the DTD and/or
processing tools are not generally available, and the
machine-generated HTML, PostScript or PDF produced by some word
processors for output purposes only.

The "Title Page" means, for a printed book, the title page itself,
plus such following pages as are needed to hold, legibly, the material
this License requires to appear in the title page.  For works in
formats which do not have any title page as such, "Title Page" means
the text near the most prominent appearance of the work's title,
preceding the beginning of the body of the text.

The "publisher" means any person or entity that distributes copies of
the Document to the public.

A section "Entitled XYZ" means a named subunit of the Document whose
title either is precisely XYZ or contains XYZ in parentheses following
text that translates XYZ in another language.  (Here XYZ stands for a
specific section name mentioned below, such as "Acknowledgements",
"Dedications", "Endorsements", or "History".)  To "Preserve the Title"
of such a section when you modify the Document means that it remains a
section "Entitled XYZ" according to this definition.

The Document may include Warranty Disclaimers next to the notice which
states that this License applies to the Document.  These Warranty
Disclaimers are considered to be included by reference in this
License, but only as regards disclaiming warranties: any other
implication that these Warranty Disclaimers may have is void and has
no effect on the meaning of this License.

2. VERBATIM COPYING

You may copy and distribute the Document in any medium, either
commercially or noncommercially, provided that this License, the
copyright notices, and the license notice saying this License applies
to the Document are reproduced in all copies, and that you add no
other conditions whatsoever to those of this License.  You may not use
technical measures to obstruct or control the reading or further
copying of the copies you make or distribute.  However, you may accept
compensation in exchange for copies.  If you distribute a large enough
number of copies you must also follow the conditions in section 3.

You may also lend copies, under the same conditions stated above, and
you may publicly display copies.


3. COPYING IN QUANTITY

If you publish printed copies (or copies in media that commonly have
printed covers) of the Document, numbering more than 100, and the
Document's license notice requires Cover Texts, you must enclose the
copies in covers that carry, clearly and legibly, all these Cover
Texts: Front-Cover Texts on the front cover, and Back-Cover Texts on
the back cover.  Both covers must also clearly and legibly identify
you as the publisher of these copies.  The front cover must present
the full title with all words of the title equally prominent and
visible.  You may add other material on the covers in addition.
Copying with changes limited to the covers, as long as they preserve
the title of the Document and satisfy these conditions, can be treated
as verbatim copying in other respects.

If the required texts for either cover are too voluminous to fit
legibly, you should put the first ones listed (as many as fit
reasonably) on the actual cover, and continue the rest onto adjacent
pages.

If you publish or distribute Opaque copies of the Document numbering
more than 100, you must either include a machine-readable Transparent
copy along with each Opaque copy, or state in or with each Opaque copy
a computer-network location from which the general network-using
public has access to download using public-standard network protocols
a complete Transparent copy of the Document, free of added material.
If you use the latter option, you must take reasonably prudent steps,
when you begin distribution of Opaque copies in quantity, to ensure
that this Transparent copy will remain thus accessible at the stated
location until at least one year after the last time you distribute an
Opaque copy (directly or through your agents or retailers) of that
edition to the public.

It is requested, but not required, that you contact the authors of the
Document well before redistributing any large number of copies, to
give them a chance to provide you with an updated version of the
Document.


4. MODIFICATIONS

You may copy and distribute a Modified Version of the Document under
the conditions of sections 2 and 3 above, provided that you release
the Modified Version under precisely this License, with the Modified
Version filling the role of the Document, thus licensing distribution
and modification of the Modified Version to whoever possesses a copy
of it.  In addition, you must do these things in the Modified Version:

A. Use in the Title Page (and on the covers, if any) a title distinct
   from that of the Document, and from those of previous versions
   (which should, if there were any, be listed in the History section
   of the Document).  You may use the same title as a previous version
   if the original publisher of that version gives permission.
B. List on the Title Page, as authors, one or more persons or entities
   responsible for authorship of the modifications in the Modified
   Version, together with at least five of the principal authors of the
   Document (all of its principal authors, if it has fewer than five),
   unless they release you from this requirement.
C. State on the Title page the name of the publisher of the
   Modified Version, as the publisher.
D. Preserve all the copyright notices of the Document.
E. Add an appropriate copyright notice for your modifications
   adjacent to the other copyright notices.
F. Include, immediately after the copyright notices, a license notice
   giving the public permission to use the Modified Version under the
   terms of this License, in the form shown in the Addendum below.
G. Preserve in that license notice the full lists of Invariant Sections
   and required Cover Texts given in the Document's license notice.
H. Include an unaltered copy of this License.
I. Preserve the section Entitled "History", Preserve its Title, and add
   to it an item stating at least the title, year, new authors, and
   publisher of the Modified Version as given on the Title Page.  If
   there is no section Entitled "History" in the Document, create one
   stating the title, year, authors, and publisher of the Document as
   given on its Title Page, then add an item describing the Modified
   Version as stated in the previous sentence.
J. Preserve the network location, if any, given in the Document for
   public access to a Transparent copy of the Document, and likewise
   the network locations given in the Document for previous versions
   it was based on.  These may be placed in the "History" section.
   You may omit a network location for a work that was published at
   least four years before the Document itself, or if the original
   publisher of the version it refers to gives permission.
K. For any section Entitled "Acknowledgements" or "Dedications",
   Preserve the Title of the section, and preserve in the section all
   the substance and tone of each of the contributor acknowledgements
   and/or dedications given therein.
L. Preserve all the Invariant Sections of the Document,
   unaltered in their text and in their titles.  Section numbers
   or the equivalent are not considered part of the section titles.
M. Delete any section Entitled "Endorsements".  Such a section
   may not be included in the Modified Version.
N. Do not retitle any existing section to be Entitled "Endorsements"
   or to conflict in title with any Invariant Section.
O. Preserve any Warranty Disclaimers.

If the Modified Version includes new front-matter sections or
appendices that qualify as Secondary Sections and contain no material
copied from the Document, you may at your option designate some or all
of these sections as invariant.  To do this, add their titles to the
list of Invariant Sections in the Modified Version's license notice.
These titles must be distinct from any other section titles.

You may add a section Entitled "Endorsements", provided it contains
nothing but endorsements of your Modified Version by various
parties--for example, statements of peer review or that the text has
been approved by an organization as the authoritative definition of a
standard.

You may add a passage of up to five words as a Front-Cover Text, and a
passage of up to 25 words as a Back-Cover Text, to the end of the list
of Cover Texts in the Modified Version.  Only one passage of
Front-Cover Text and one of Back-Cover Text may be added by (or
through arrangements made by) any one entity.  If the Document already
includes a cover text for the same cover, previously added by you or
by arrangement made by the same entity you are acting on behalf of,
you may not add another; but you may replace the old one, on explicit
permission from the previous publisher that added the old one.

The author(s) and publisher(s) of the Document do not by this License
give permission to use their names for publicity for or to assert or
imply endorsement of any Modified Version.


5. COMBINING DOCUMENTS

You may combine the Document with other documents released under this
License, under the terms defined in section 4 above for modified
versions, provided that you include in the combination all of the
Invariant Sections of all of the original documents, unmodified, and
list them all as Invariant Sections of your combined work in its
license notice, and that you preserve all their Warranty Disclaimers.

The combined work need only contain one copy of this License, and
multiple identical Invariant Sections may be replaced with a single
copy.  If there are multiple Invariant Sections with the same name but
different contents, make the title of each such section unique by
adding at the end of it, in parentheses, the name of the original
author or publisher of that section if known, or else a unique number.
Make the same adjustment to the section titles in the list of
Invariant Sections in the license notice of the combined work.

In the combination, you must combine any sections Entitled "History"
in the various original documents, forming one section Entitled
"History"; likewise combine any sections Entitled "Acknowledgements",
and any sections Entitled "Dedications".  You must delete all sections
Entitled "Endorsements".


6. COLLECTIONS OF DOCUMENTS

You may make a collection consisting of the Document and other
documents released under this License, and replace the individual
copies of this License in the various documents with a single copy
that is included in the collection, provided that you follow the rules
of this License for verbatim copying of each of the documents in all
other respects.

You may extract a single document from such a collection, and
distribute it individually under this License, provided you insert a
copy of this License into the extracted document, and follow this
License in all other respects regarding verbatim copying of that
document.


7. AGGREGATION WITH INDEPENDENT WORKS

A compilation of the Document or its derivatives with other separate
and independent documents or works, in or on a volume of a storage or
distribution medium, is called an "aggregate" if the copyright
resulting from the compilation is not used to limit the legal rights
of the compilation's users beyond what the individual works permit.
When the Document is included in an aggregate, this License does not
apply to the other works in the aggregate which are not themselves
derivative works of the Document.

If the Cover Text requirement of section 3 is applicable to these
copies of the Document, then if the Document is less than one half of
the entire aggregate, the Document's Cover Texts may be placed on
covers that bracket the Document within the aggregate, or the
electronic equivalent of covers if the Document is in electronic form.
Otherwise they must appear on printed covers that bracket the whole
aggregate.


8. TRANSLATION

Translation is considered a kind of modification, so you may
distribute translations of the Document under the terms of section 4.
Replacing Invariant Sections with translations requires special
permission from their copyright holders, but you may include
translations of some or all Invariant Sections in addition to the
original versions of these Invariant Sections.  You may include a
translation of this License, and all the license notices in the
Document, and any Warranty Disclaimers, provided that you also include
the original English version of this License and the original versions
of those notices and disclaimers.  In case of a disagreement between
the translation and the original version of this License or a notice
or disclaimer, the original version will prevail.

If a section in the Document is Entitled "Acknowledgements",
"Dedications", or "History", the requirement (section 4) to Preserve
its Title (section 1) will typically require changing the actual
title.


9. TERMINATION

You may not copy, modify, sublicense, or distribute the Document
except as expressly provided under this License.  Any attempt
otherwise to copy, modify, sublicense, or distribute it is void, and
will automatically terminate your rights under this License.

However, if you cease all violation of this License, then your license
from a particular copyright holder is reinstated (a) provisionally,
unless and until the copyright holder explicitly and finally
terminates your license, and (b) permanently, if the copyright holder
fails to notify you of the violation by some reasonable means prior to
60 days after the cessation.

Moreover, your license from a particular copyright holder is
reinstated permanently if the copyright holder notifies you of the
violation by some reasonable means, this is the first time you have
received notice of violation of this License (for any work) from that
copyright holder, and you cure the violation prior to 30 days after
your receipt of the notice.

Termination of your rights under this section does not terminate the
licenses of parties who have received copies or rights from you under
this License.  If your rights have been terminated and not permanently
reinstated, receipt of a copy of some or all of the same material does
not give you any rights to use it.


10. FUTURE REVISIONS OF THIS LICENSE

The Free Software Foundation may publish new, revised versions of the
GNU Free Documentation License from time to time.  Such new versions
will be similar in spirit to the present version, but may differ in
detail to address new problems or concerns.  See
https://www.gnu.org/licenses/.

Each version of the License is given a distinguishing version number.
If the Document specifies that a particular numbered version of this
License "or any later version" applies to it, you have the option of
following the terms and conditions either of that specified version or
of any later version that has been published (not as a draft) by the
Free Software Foundation.  If the Document does not specify a version
number of this License, you may choose any version ever published (not
as a draft) by the Free Software Foundation.  If the Document
specifies that a proxy can decide which future versions of this
License can be used, that proxy's public statement of acceptance of a
version permanently authorizes you to choose that version for the
Document.

11. RELICENSING

"Massive Multiauthor Collaboration Site" (or "MMC Site") means any
World Wide Web server that publishes copyrightable works and also
provides prominent facilities for anybody to edit those works.  A
public wiki that anybody can edit is an example of such a server.  A
"Massive Multiauthor Collaboration" (or "MMC") contained in the site
means any set of copyrightable works thus published on the MMC site.

"CC-BY-SA" means the Creative Commons Attribution-Share Alike 3.0
license published by Creative Commons Corporation, a not-for-profit
corporation with a principal place of business in San Francisco,
California, as well as future copyleft versions of that license
published by that same organization.

"Incorporate" means to publish or republish a Document, in whole or in
part, as part of another Document.

An MMC is "eligible for relicensing" if it is licensed under this
License, and if all works that were first published under this License
somewhere other than this MMC, and subsequently incorporated in whole or
in part into the MMC, (1) had no cover texts or invariant sections, and
(2) were thus incorporated prior to November 1, 2008.

The operator of an MMC Site may republish an MMC contained in the site
under CC-BY-SA on the same site at any time before August 1, 2009,
provided the MMC is eligible for relicensing.


ADDENDUM: How to use this License for your documents

To use this License in a document you have written, include a copy of
the License in the document and put the following copyright and
license notices just after the title page:

    Copyright (c)  YEAR  YOUR NAME.
    Permission is granted to copy, distribute and/or modify this document
    under the terms of the GNU Free Documentation License, Version 1.3
    or any later version published by the Free Software Foundation;
    with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
    A copy of the license is included in the section entitled "GNU
    Free Documentation License".

If you have Invariant Sections, Front-Cover Texts and Back-Cover Texts,
replace the "with...Texts." line with this:

    with the Invariant Sections being LIST THEIR TITLES, with the
    Front-Cover Texts being LIST, and with the Back-Cover Texts being LIST.

If you have Invariant Sections without Cover Texts, or some other
combination of the three, merge those two alternatives to suit the
situation.

If your document contains nontrivial examples of program code, we
recommend releasing these examples in parallel under your choice of
free software license, such as the GNU General Public License,
to permit their use in free software.
</pre>
#+end_export

#+html: <!--

* Indices
:PROPERTIES:
:CUSTOM_ID: h:indices
:END:

** Function index
:PROPERTIES:
:INDEX: fn
:CUSTOM_ID: h:function-index
:END:

** Variable index
:PROPERTIES:
:INDEX: vr
:CUSTOM_ID: h:variable-index
:END:

** Concept index
:PROPERTIES:
:INDEX: cp
:CUSTOM_ID: h:concept-index
:END:

#+html: -->
