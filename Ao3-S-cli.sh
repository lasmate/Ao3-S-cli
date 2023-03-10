#!/bin/sh

menu_select(){ #creates a menu based on the function that calls it 
    #only for prototypyng/future use 
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
search_author(){ #functional
    echo "input author name"
    read -p ":: " author_name
    author_list_untreated=$(curl -s https://archiveofourown.org/people/search?people_search%5Bname%5D=$author_name |grep -Eoi '"/users[^\"]+"' |sed 's/\"//g'|tr ' ' '\n' |tr '/' '\n'| sort -u |tr '\n' ' ') 
    author_list_treated=$(echo $author_list_untreated | sed 's/users//g'|sed 's/login//g' |sed 's/password//g'|sed 's/new//g' | sed 's/pseuds//g') 
        inc=1 
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
search_work(){ 
    # if have the feeling having a separate function to search only works might be very useless butg a refactor seems dumb until most othe funcs are coded AND work 
    echo "input work name"
    read -p ":: " work_name


}
select_work(){ #functional
    work_list_untreated=$(curl -s https://archiveofourown.org/users/$author_id/works | grep -Eoi '"/works[^\"]+/')
    work_list_treated=$( echo $work_list_untreated | sed 's/\"//g'|tr ' ' '\n' |tr '/' '\n'| sort -u |tr '\n' ' ' |sed 's/chapters//g' |sed 's/works//g')

    inc=1
    for i in $work_list_treated; do # really slow and inefficient but it works
        work_name_temp=$(curl -s https://archiveofourown.org/works/$i | grep -oP '<a href="/works/[0-9]+">[\s\S]+</a>' | sed 's/<a href="\/works//g' | sed 's/<\/a>//g'|tr '">' ' ')
        echo $inc $work_name_temp
        inc=$((inc+1))
    done
    echo "select the work"
    echo "type 'q' to quit"
    read -p ":: " arg
    while [ $arg != "q" ]; do
        if [ $arg -gt $inc ]; then
            echo "invalid input"
        else
            echo "1.read 2.download 3.back"
            read -p ":: " arg2
            case $arg2 in
                1)
                    work_id=$(echo $work_list_treated | cut -d ' ' -f $arg)
                    select_chapter $work_id
                    ;;
                2)
                    work_id=$(echo $work_list_treated | cut -d ' ' -f $arg)
                    dl_work $work_id
                    ;;
                3)
                    search_author
                    ;;
                *)
                    echo "invalid input"
                    exit 1
                    ;;
            esac
        fi
    done
}
select_chapter(){ #future me this is very redundant and bloated please find a way to clean it up
    work_id=$1
    chapter_list_id=$(curl -s https://archiveofourown.org/works/$work_id/navigate |grep -Eoi 'chapters/[0-9]+">[0-9]+. [^<]+</a> <span class="datetime">[^<]+' | sed 's/<li><a href="\/works//g'| sed 's/<\/a> <span class="datetime">//g' | sed 's/<\/li>//g' | sed 's/chapters//g' | tr '">' ' '| cut -d ' ' -f 1 | tr '\n' ' ' |sed 's/\///g')
    chapter_list_names=$(curl -s https://archiveofourown.org/works/$work_id/navigate |grep -Eoi 'chapters/[0-9]+">[0-9]+. [^<]+</a> <span class="datetime">[^<]+' | sed 's/<li><a href="\/works//g'| sed 's/<\/a> <span class="datetime">//g' | sed 's/<\/li>//g' | sed 's/chapters//g' | tr '">' ' '| cut -d ' ' -f 4- | tr ' ' '_')
    
    inc=1
    for i in $chapter_list_names; do
        echo $inc $i
        inc=$((inc+1))
    done
    echo " select chapter"
    echo " type q to quit"
    read -p ":: " arg
    while [ $arg != "q" ]; do
        if [ $arg -gt $inc ]; then
            echo "invalid input"
        else
            chapter_id=$(echo $chapter_list_id | cut -d ' ' -f $arg)
            chapter_name=$(echo $chapter_list_names | cut -d ' ' -f $arg)
            scrape_chapter $work_id $chapter_id $chapter_name
        fi
    done
}
#/41540862
dl_work(){ #functional bc of implemented dl method in the base website
    work_id=$1
    work_name_web=$(curl https://archiveofourown.org/works/$work_id | grep -oP 'ks/[0-9]+">[\s\S]+</a>' |sed 's/ks\///g'| sed 's/<\/a>//g' |sed -e 's/ /%20/g'|tr '">' ' ' | cut -d ' ' -f 2-)
    echo $work_name_web
    semilink="$work_id/$work_name_web"
    semilink=$(echo $semilink | sed -e 's/ //g')
    echo $semilink
    echo "downloading work"

    aria2c https://archiveofourown.org/downloads/$semilink.pdf
    exit 0
}
scrape_chapter(){ #non functionnal, requiresnuch more work to dl specific chapters and not the whole work
    work_id=$1
    chapter_id=$2
    chapter_name=$3
    chapter_name_web=$(echo $chapter_name |tr '_' '%20')
    echo "scraping chapter $chapter_id"
    wget -q https://archiveofourown.org/download/$work_id/$ -O chapter
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
while [ $arg != "q" ]; do
    case $arg in
        r)
            resume;;
        a) 
            search_author;;
        t) 
            search_tag;;
        w)
            search_work;;
        h)
            echo "availiable options : w,t,a,h,q"
            echo "-r : resume last chapter"
            echo "-w : search for a work"
            echo "-t : search for a tag"
            echo "-a : search for an author"
            echo "-h : help"
            ;;
        q)
            echo ""
            exit 1;;
        z)
            echo "test"
            dl_work 41540862
            ;;
        *)
            echo "invalid input";;
    esac
done