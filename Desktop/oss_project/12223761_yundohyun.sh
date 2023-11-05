#!/bin/bash


get_movie_data() {
    local movie_id=$1
    local movie_info=$(grep "^$movie_id|" u.item)
    if [ -n "$movie_info" ]; then
        echo "Movie Information for Movie ID $movie_id:"
        echo "$movie_info"
     else
        echo "Movie not found for Movie ID $movie_id."
    fi
} 

get_action_genre() {
    awk -F'|' '{
    split($6, genres, " ");
    if (genres[2] == 1) {
        print $1, $2;
    }
}' u.item | sort -n | head -n 10
}




get_average_rating() {
    local movie_id="$1"
    awk -F'\t' -v id="$movie_id" '$1 == id { sum += $3; count++ } END { if (count > 0) print sum / count }' u.data
}

delete_imdb_url() {
    sed -i 's/|http:\/\/us\.imdb\.com\/M\/title-exact\?[^|]*|/|/g' input_file
    sort -t '|' -k1,1n new_u.item | head -n 10
}

get_average_rating_programmers() {
    local movie_id="$1"

    awk -v id="$movie_id" -F'\t' '$1 == id { print $3 }' u.data |
    awk '{ sum += $1; count++ } END { printf "%.6f\n", sum/count }'
}

main() {
    echo "—————————————"
    echo "사용자 이름: yundohyun"
    echo "학생 번호: 12223761"
    echo "[ 메뉴 ]"
    echo "1. 'u.item'에서 특정 '영화 id'로 식별된 영화 데이터 가져오기"
    echo "2. 'u.item'에서 '액션' 장르 영화 데이터 가져오기"
    echo "3. 'u.data'에서 특정 '영화 id'의 평균 '평점' 가져오기"
    echo "4. 'u.item'에서 'IMDb URL' 삭제하기"
    echo "5. 'u.user'에서 사용자 데이터 가져오기"
    echo "6. 'u.item'의 '개봉일' 형식 수정하기"
    echo "7. 'u.data'에서 특정 '사용자 id'가 평가한 영화 데이터 가져오기"
    echo "8. '나이'가 20에서 29이고 '직업'이 '프로그래머'인 사용자가 평가한 영화의 평균 '평점' 가져오기"
    echo "9. 종료"
    echo "—————————————"

    while true; do
        read -p "선택하세요 [ 1-9 ] " choice
        echo

        case $choice in
            1)
                read -p "영화 id를 입력하세요 (1~1682): " movie_id
		get_movie_data $movie_id
                ;;

            2)
                read -p "'액션' 장르 영화 데이터를 가져올까요?(y/n): " confirm
                if [ "$confirm" == "y" ]; then
			get_action_genre
                else
                    echo "액션 영화 검색이 취소되었습니다."
                fi
                ;;

            3)
                read -p "영화 id를 입력하세요 (1~1682): " movie_id

    result=$(get_average_rating "$movie_id")

    if [ -n "$result" ]; then
        printf "Average Rating for Movie ID %s: %.6f\n" "$movie_id" "$result"
    else
        echo "No data found for the provided movie ID."
    fi
                ;;

            4)
                read -p "'u.item'에서 'IMDb URL'을 삭제할까요?(y/n): " confirm
                if [ "$confirm" == "y" ]; then
                    sed 's/|\(http:\/\/us\.imdb\.com\/M\/title-exact\?[^|]*\)//' u.item > u.item.tmp

sort -t '|' -k1,1n u.item.tmp | head -n 10

rm u.item.tmp
                else
                    echo "IMDb URL 삭제가 취소되었습니다."
                fi
                ;;

            5)
                read -p "'u.user'에서 사용자 데이터를 가져올까요?(y/n): " confirm
                if [ "$confirm" == "y" ]; then
                    awk -F'|' '{printf "user %s is %s years old %s %s\n", $1, $2, $3, $4}' u.user | sort -n -t ' ' -k2,2| head -n 10
                else
                    echo "사용자 데이터 검색이 취소되었습니다."
                fi
                ;;

            6)
                read -p "'u.item'의 '개봉일' 형식을 수정할까요?(y/n): " confirm
                if [ "$confirm" == "y" ]; then
                    sed -i 's/\([0-9]\{2\}\)-\([A-Za-z]\{3\}\)-\([0-9]\{4\}\)/\3\2\1/' u.item

tail -n +$(( $(wc -l < u.item) - 9 )) u.item | sort -t '|' -k1,1n | head -n 10
                else
                    echo "개봉일 형식 수정이 취소되었습니다."
                fi
                ;;

            7)
                read -p "사용자 id를 입력하세요 (1~943): " user_id
                data_records=$(awk -v num="$user_number" '$1 == num' u.data)

result_records=$(echo "$data_records" | awk 'FNR==NR{a[$1]; next} $2 in a' - u.item)

echo "$result_records" | sort -t '|' -k1,1n | head -n 10 | awk -F'|' '{print $1, $2}'
                ;;

            8)
                read -p "'나이'가 20에서 29이고 '직업'이 '프로그래머'인 사용자가 평가한 영화의 평균 '평점'을 가져올까요?(y/n): " confirm
                if [ "$confirm" == "y" ]; then
                    echo "1"
                else
                    echo "평균 평점 검색이 취소되었습니다."
                fi
                ;;

            9)
               echo "bye!"
                exit 0
                ;;

	esac
    done
}
main $1 $2 $3
