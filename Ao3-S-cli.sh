
search_tag(){
    echo "input tag name"
    read -p ":: " tag_name
    curl https://archiveofourown.org/tags/search?tag_search%5Bname%5D=$tag_name&tag_search%5Bfandoms%5D=&tag_search%5Btype%5D=&tag_search%5Bcanonical%5D=&tag_search%5Bsort_column%5D=name&tag_search%5Bsort_direction%5D=asc&commit=Search+Tags
    
}
search_author(){ #searches liste of author
    echo "input author name"
    read -p ":: " author_name
    author_list_untreated = curl https://archiveofourown.org/people/search?people_search%5Bname%5D=$author_name |grep -Eoi '"/users[^\"]+"' ||sed 's/\"//g'|tr ' ' '\n' |tr '/' '\n'| sort -u |tr '\n' ' ' #gets list of authors and removes any duplicates and puts them in a list
    author_list_sanitised = echo $author_list_untreated |sed 's/login//g' |sed 's/password//g'|sed 's/new//g' | sed 's/users\///g' #removes any unwanted strings from the list
    while arg!="q";do #loops until user quits
        echo "select author"
        inc=2 # cut -d ' ' -f 1 is the first element(empty in this case) in the list so the first element is 2
        for i in $author_list_sanitised; do #iterates through the list

            echo $inc,$i
            inc=($inc+1) 
        done
        echo "type the corresponding number to browse the authors work"
        echo "type 'q' to quit"
        read -p ":: " arg
        if arg=="q"
        then
            exit 1
        elif $arg>$inc
            echo "invalid input"
        else 
            author_id = echo $author_list_sanitised | cut -d ' ' -f $arg
        ; done
    
}
search_work(){
    echo "input work name"
    read -p ":: " story_name
    curl https://archiveofourown.org/works/search/?utf8=%E2%9C%93&work_search%5Bquery%5D=$work_name 
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
Q: how to get the chapter list?
 
A: curl https://archiveofourown.org/works/$story_id/navigate | grep -oP '(?<=<li><a href="/works/)[0-9]+(?=/chapters/)[0-9]+(?=">)[0-9]+(?=</a></li>)' 
    this is the command to get the chapter list
    the output is a list of chapter ids
    the list is stored in the variable chapter_list
    the list is printed with echo $chapter_list
    
    the list is iterated with for i in $chapter_list; do curl https://archiveofourown.org/works/$story_id/chapters/$i | grep -oP '(?<=<div class="userstuff module">)[\s\S]+(?=</div>)' | pandoc -f html -t plain | less; done # less is a text viewer

menu(){
    echo "Ao3-S-cli"
    echo "type 'a' to search for a story"
    echo "type 'h' to search for a tag"
    echo "type 'q' to quit"
    arg=""
    while $arg!="q"; do
        read -p ":: " arg
        case $arg in :
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
    done
}
menu