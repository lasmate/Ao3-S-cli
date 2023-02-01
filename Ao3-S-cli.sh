menu_select(){ #creates a menu based on the function that calls it 
    echo "select $1"
    inc=1 # cut -d ' ' -f 0 is the first element(empty in this case) in the list so the first element is 1
    for i in $2; do #iterates through the list
        echo $inc,$i
        inc=$((inc+1))
    done
    echo "type the corresponding number to browse the $1"
    echo "type 'q' to quit"
    read -p ":: " arg
    while [ $arg != "q" ]; do
        if [ $arg -gt $inc ]; then
            echo "invalid input"
        else
            $3=$(echo $2 | cut -d ' ' -f $arg)
            $4
        fi
    done

}
search_tag(){
    echo "input tag name"
    read -p ":: " tag_name
    tag_list_untreated=$(curl -s https://archiveofourown.org/tags/search?tag_search%5Bname%5D=$tag_name&tag_search%5Bsort_direction%5D=asc&commit=Search+Tags |grep -Eoi '"/works[^\"]+"') 
    tag_list_sanitised=$(echo $tag_list_untreated |sed 's/login//g' |sed 's/password//g'|sed 's/new//g' | sed 's/users\///g') #removes any unwanted strings from the list
    if [tag_list_sanitised != " "];then
        echo "works found under $tag_name"
        for i in tag_list_sanitised; do
            work_name_temp=$(https://archiveofourown.org/tags/$tag_name/works  grep -oP '(?<=<h2 class="title heading">)[\s\S]+(?=</h2>)' | sed 's/\"//g')
            echo $i
        done
    fi
}
search_author(){ #functional
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
        echo "select author"
        echo "type 'q' to quit"
        read -p ":: " arg
        while [ $arg != "q" ]; do
            if [ $arg -gt $inc ]; then
                echo "invalid input"
            else
                author_id=$(echo $author_list_treated | cut -d ' ' -f $arg)
                select_work $author_id 
                
            fi
        done
    
}
search_work(){ # if have the feeling having a separate function to search only works might be very useless butg a refactor seems dumb until most othe funcs are coded AND work 
    #pretty complicated for now doing that shit later 
    # for some reason ( me being dumb) grep shows no output when i use it to get the list of works 
    echo "input work name"
    read -p ":: " work_name

}

select_work(){# functional
    work_list_untreated=$(curl -s https://archiveofourown.org/users/$author_id/works | grep -Eoi '"/works[^\"]+/')
    work_list_treated=$( echo $work_list_untreated | sed 's/\"//g'|tr ' ' '\n' |tr '/' '\n'| sort -u |tr '\n' ' ' |sed 's/chapters//g' |sed 's/works//g')
    # transform this into a simple increment based menu bc typing +8 numbers is realy nt user friendly 
    # should work for now tho
    inc=1
    for i in $work_list_treated; do 
        #curl the name of the work fro mthe corresponging id and echo it         
        work_name_temp=$(curl -s https://archiveofourown.org/works/$i | grep -oP '<a href="/works/[0-9]+">[\s\S]+</a>' | sed 's/<a href="\/works//g' | sed 's/<\/a>//g'|tr '">' ' ')
        echo $inc70 $work_name_temp
        inc=$((inc+1))
    done
    echo "select the work"
    echo "type 'q' to quit"
    read -p ":: " arg
    while [ $arg != "q" ]; do
        if [ $arg -gt $inc ]; then
            echo "invalid input"
        else
            work_id=$(echo $work_list_treated | cut -d ' ' -f $arg)
            select_chapter $work_id
        fi
    done

}


select_chapter(){
    work_id=$1
    chapter_list= curl https://archiveofourown.org/works/$story_id/navigate | grep -oP '(?<=<li><a href="/works/)[0-9]+(?=/chapters/)[0-9]+(?=">)[0-9]+(?=</a></li>)') #gets list of chapters and removes any duplicates and puts them in a list
    echo "select chapter"
    echo "type 'q' to quit"
    read -p ":: " arg
    while [ $arg != "q" ]; do
        if [ $arg -gt $inc ]; then
            echo "invalid input"
        else
            chapter_id=$(echo $chapter_list | cut -d ' ' -f $arg)
            scrape_chapter $chapter_id $story_id
        fi
    done
}
#   the list is iterated with for i in $chapter_list; do curl https://archiveofourown.org/works/$story_id/chapters/$i | grep -oP '(?<=<div class="userstuff module">)[\s\S]+(?=</div>)' | pandoc -f html -t plain | less; done # less is a text viewer
scrape_chapter(){ #scrapres content of the chapter redirects in into stdout and pipe into zathura
    chapter_content=$(curl https://archiveofourown.org/works/$story_id/chapters/$chapter_id | grep -oP '(?<=<div class="userstuff module">)[\s\S]+(?=</div>)' | pandoc -f html -t plain)
    echo $chapter_content | zathura - #zathura is a pdf viewer
    
}
resume_chapter(){
    #in construction 
    #resumes chapter and works from hist file
    echo "resuming last chapter"
    chapter_id=$(cat hist | grep -oP '(?<=chapter_id:)[0-9]+')
    story_id=$(cat hist | grep -oP '(?<=story_id:)[0-9]+')
    
}
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
    r)
        resume
        ;;
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

