
search_tag(){
    echo "input tag name"
    read -p ":: " tag_name
    tag_list_untreated=$(curl -s https://archiveofourown.org/tags/search?tag_search%5Bname%5D=$tag_name&tag_search%5Bsort_direction%5D=asc&commit=Search+Tags |grep -Eoi '"/works[^\"]+"') 
    tag_list_sanitised=$(echo $tag_list_untreated |sed 's/login//g' |sed 's/password//g'|sed 's/new//g' | sed 's/users\///g') #removes any unwanted strings from the list
    if [tag_list_sanitised != " "]
        echo "works found under $tag_name"
        for i in tag_list_sanitised; do
            work_name_temp=$(https://archiveofourown.org/tags/$tag_name/works  grep -oP '(?<=<h2 class="title heading">)[\s\S]+(?=</h2>)' | sed 's/\"//g')
            echo $i
}
search_author(){ #searches list of author
    echo "input author name"
    read -p ":: " author_name
    author_list_untreated=$(curl -s https://archiveofourown.org/people/search?people_search%5Bname%5D=$author_name |grep -Eoi '"/users[^\"]+"' |sed 's/\"//g'|tr ' ' '\n' |tr '/' '\n'| sort -u |tr '\n' ' ') #gets list of authors and removes any duplicates and puts them in a list
    author_list_treated=$(echo $author_list_untreated | sed 's/users//g'|sed 's/login//g' |sed 's/password//g'|sed 's/new//g' | sed 's/pseuds//g') #removes any unwanted strings from the list
        echo "select author"
        inc=1 # cut -d ' ' -f 0 is the first element(empty in this case) in the list so the first element is 1
        for i in $author_list_treated; do #iterates through the list
            echo $inc,$i
            inc=$((inc+1))
        done
        echo "type the corresponding number to browse the authors work"
        echo "type 'q' to quit"
        read -p ":: " arg
        while [ $arg != "q" ]; do
            if [ $arg -gt $inc ]; then
                echo "invalid input"
            else
                author_id=$(echo $author_list_treated | cut -d ' ' -f $arg)
                search_work $author_id 
                
            fi
        done
    
}
search_work(){ # if have the feeling having a separate function to search only works might be very useless butg a refactor seems dumb until most othe funcs are coded AND work 
    echo "input work name"
    read -p ":: " story_name
    work_list_untreated=$(curl https://archiveofourown.org/works/search/?utf8=%E2%9C%93&work_search%5Bquery%5D=$work_name)
}

select_work(){
    work_list_untreated=$(curl https://archiveofourown.org/users/$author_id/works | grep -Eoi '"/works[^\"]+/')
    work_list_treated=$( echo $work_list_untreated | sed 's/\"//g'|tr ' ' '\n' |tr '/' '\n'| sort -u |tr '\n' ' ' |sed 's/chapters//g' |sed 's/works//g')
    # transform this into a simple increment based menu bc typing +8 numbers is realy nt user friendly 
    # should work for now tho 
    for i in $work_list_treated; do         
        work_name_temp=$(curl -s https://archiveofourown.org/works/$i | grep -oP '(?<=<h2 class="title heading">)[\s\S]+(?=</h2>)' | sed 's/\"//g')
        echo $i, $work_name_temp
    done
    echo "type the corresponding number to browse the work"
    echo "type 'q' to quit"
    read -p ":: " arg
    while [ $arg != "q" ]; do
        if [ $arg in work_list_treated ]; then
            work_id=$(echo $work_list_treated | cut -d ' ' -f $arg)
            chapter_select
        else
            echo "invalid input"
        fi
    done

}

resume_chapter(){
    echo "resuming last chapter"
    chapter_id = cat history.txt | grep -oP '(?<=chapter_id: )[0-9]+'
}
chapter_select(){
    if story_name==""
    then
        echo "no story selected"
        echo "resume last story chapter read? (y/n)"
        read -p ":: " resume
        if resume=="y"
        then
            echo "resuming last story chapter"
            resume_chapter
        else
            exit 1
        fi
    fi
    chapter_list= curl https://archiveofourown.org/works/$story_id/navigate | grep -oP '(?<=<li><a href="/works/)[0-9]+(?=/chapters/)[0-9]+(?=">)[0-9]+(?=</a></li>)' 
}
#   the list is iterated with for i in $chapter_list; do curl https://archiveofourown.org/works/$story_id/chapters/$i | grep -oP '(?<=<div class="userstuff module">)[\s\S]+(?=</div>)' | pandoc -f html -t plain | less; done # less is a text viewer

echo "Ao3-S-cli"
echo "
    ==========
    | w/ork  |
    | t/ag   |
    | a/uthor|
    | h/elp  |
    | q/uit  |
    ==========
"
read -p ":: " arg
case $arg in
    w)
        search_work
        ;;
    t) 
        search_tag
        ;;
    a) 
        search_author
        ;;
    h)
        echo "availiable options : w,t,a,h,q"
        echo "-w : search for a story"
        echo "-t : search for a tag"
        echo "-a : search for an author"
        echo "-h : help"
        ;;
    q)
        echo ""
        exit 1
        ;;
    *)
        echo "invalid input"
        ;;
esac

