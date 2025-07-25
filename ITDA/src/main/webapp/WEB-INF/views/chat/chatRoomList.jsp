<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="sec"
	uri="http://www.springframework.org/security/tags"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>ChattingRoomList</title>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<link
	href="${pageContext.request.contextPath}/resources/css/globals.css"
	rel="stylesheet">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/chat-style.css">

<!-- 각 모달 css 기술 -->
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/modal_css/shipping_Inform.css">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/modal_css/shipping_Address.css">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/modal_css/account_Input.css">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/modal_css/shipping_Address.css">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/modal_css/manner_Review.css">

<c:set var="contextPath" value="${pageContext.request.contextPath}" />

</head>

<body>
	<!-- 카카오 우편번호 API -->
	<script
		src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

	<div class="chat-wrapper">

		<!-- 왼쪽 채팅창 -->
		<div class="chatlist-container">
			<div class="chat-header1">
				<!-- 거래 유형 -->
				<span id="chatTypeLabel">전체 채팅방</span>
				<!-- '전체 채팅방' 디폴트 -->
				<!-- '+'버튼 누르면 채팅방 유형별 뜨도록 -->

				<!-- 채팅 유형 버튼 -->
				<button class="ellipse-button-chatRoomType" onclick="chatRoomType()">
					<b>채팅방 선택</b>
				</button>

				<!-- 채팅방 생성 -->
				<!-- 
					상품 상세 조회에서 채팅방으로 넘어올 데이터
					 - 상대 회원 번호 (PROFILE, USER_TB)
					 - 해당 상세 사이트에서의 게시물 ID (BOARD_COMMON)
					 
				 	필요 로직
				 	 - 현재 회원 번호와 게시물 작성자 회원 번호를 채팅방에 할당
				 -->
				<button class="ellipse-button-chatRoomType"
					onclick="getBoardInfo(51)">
					<b>게시물에서 채팅방 생성</b>
				</button>

				<script>
				// 게시물 정보 받아오기 & openChatRoom컨트롤러에 바로 보냄
				// boardId 51번으로 고정
					// 전역 변수
					let boardInfo = null;
					let infoBoardId = null;
					
					function getBoardInfo(boardId) {
					fetch("${contextPath}/chat/selectBoardInfo?boardId=" + boardId, {
				    	method: "GET"
				    	})
					      .then(response => {
					        if (!response.ok) throw new Error("게시물 정보 응답 실패");
					        return response.json(); // 컨트롤러에서 보낸 JSON 객체를 JS 객체로 파싱
					      })
					      .then(data => {
					        console.log("게시물 정보:", data);
					        boardInfo = data; 
					        infoBoardId = data.boardId;
					        
					        return fetch("${contextPath}/chat/openChatRoom" ,{
					        	method: "POST",
					        	headers: {
					                "Content-Type": "application/json"
					              },
					              body: JSON.stringify(boardInfo)
					        });
					      })
					      .then(response => {
					    	  if (!response.ok) throw new Error("채팅방 열기 실패");
					      })
					      .catch(err => console.error("오류 발생:", err));    
					  	}			
				</script>

				<div id="chatMenu" class="chat-menu hidden">
					<button class="chat-type" onclick="filterChatByType('전체 채팅방')">전체
						채팅방</button>
					<button class="chat-type" onclick="filterChatByType('교환')">교환</button>
					<button class="chat-type" onclick="filterChatByType('대여')">대여</button>
					<button class="chat-type" onclick="filterChatByType('경매')">경매</button>
					<button class="chat-type" onclick="filterChatByType('나눔')">나눔</button>
					<button class="chat-type" onclick="filterChatByType('오픈채팅방')">오픈채팅방</button>

					<script>
		            // 상단 텍스트 바꾸는 함수
		            function filterChatByType(type) {
		              const chatList = document.querySelectorAll(".list-chat");
		
		              chatList.forEach(chat => {
		                const chatType = chat.getAttribute("data-chat-type");
		                // 교환인지, 나눔인지, 경매인지 얻어옴
		
		                // '전체 채팅방'일 때는 모두 보이게
		                if (type === "전체 채팅방" || chatType === type) {
		                  chat.style.display = "flex";
		                } else {
		                  chat.style.display = "none";
		                }
		              });
		
		              // 상단 라벨 변경
		              const label = document.getElementById("chatTypeLabel");
		              if (label) label.textContent = type;
		
		              // 메뉴 닫기
		              const menu = document.getElementById("chatMenu");
		              if (menu) menu.classList.add("hidden");
		            }
		          </script>
				</div>
			</div>
			<script>
			// 왼쪽 채팅창 마지막 메세지 가져오기
				function bringLastMessage(chatRoomId) {
				    console.log("chatRoomId:", chatRoomId);
				    fetch("${contextPath}/chat/bringLastMessage?chatRoomId=" + chatRoomId, {
				      method: "GET"
				    })
				    .then(res => {
				      if (!res.ok) throw new Error("메세지 못 받아옴");
				      return res.json(); 
				    })
				    .then(({lastMessage}) => {
				      const targetDiv = document.getElementById("lastMessage-" + chatRoomId);
				      if (targetDiv) targetDiv.textContent = lastMessage;
				    })
				    .catch(err => console.error("마지막 메시지 로드 실패:", err));
				}
			</script>

			<!-- 채팅방이 살아 있는 경우 -->
			<c:forEach var="chatRoom" items="${chatRoomList}">
				<c:choose>
					<c:when test="${chatRoom.status == 'Y'}">
						<!-- 채팅 리스트 -->
						<div class="chat-content1">
							<!-- 각각의 채팅방 속성 -->
							<div class="list-chat" data-chat-type="${chatRoom.refName}"
								data-chat-room-id="${chatRoom.chatRoomId}"
								data-open-chat-room-name="${chatRoom.openChatRoomName}"
								data-chat-nickname="${chatRoom.nickName}"
								data-board-id="${chatRoom.boardId}"
								data-open-chat-count="${chatRoom.openChatCount}"
								data-chat-userNum="${chatRoom.userNum}"
								style="display: flex; align-items: center; justify-content: space-between; width: 100%;">

								<!-- 프로필 버튼 누르면 유저 페이지로 이동 -->
								<button class="profile-button" onclick="goToUserPage('user123')">
									<!-- 프로필 이미지 및 오픈채팅방 대표 이미지 경로 할당 필요 -->
									<img src="${contextPath}/resources/images/chat/personEx.png"
										alt="프로필 이미지" width="50" height="50"
										style="border-radius: 20%;" />
								</button>

								<div style="flex: 1; margin-left: 20px;">
									<!-- 상대 닉네임 or 오픈채팅방 제목 -->
									<c:choose>
										<c:when test="${chatRoom.refNum == 5}">
											<!-- 오픈채팅방인 경우 오픈채팅방 제목 -->
											<div class="chatname">${chatRoom.openChatRoomName}</div>
										</c:when>
										<c:otherwise>
											<!-- 거래채팅방인 경우 거래채팅방 제목 -->
											<div class="chatname">${chatRoom.nickName}</div>
										</c:otherwise>
									</c:choose>
									<div class="lastM" id="lastMessage-${chatRoom.chatRoomId}"></div>
									<script>
									/* 마지막 메세지 */
								    	bringLastMessage('${chatRoom.chatRoomId}')
								    </script>
								</div>
								<!-- 오른쪽: 햄버거 버튼 + 메뉴 -->
								<div style="position: relative;">
									<img
										src="${pageContext.request.contextPath}/resources/images/chat/hamburger-option.png"
										alt="채팅방 옵션" width="30" height="30"
										style="border-radius: 10%; cursor: pointer;"
										onclick="toggleActionMenu(this)" />
									<!-- 채팅 버튼 신고하기, 대화나가기 -->
									<div class="exit-report-menu hidden">
										<button class="exit-report-button" onclick="reportChat()">🚩
											신고하기</button>
										<button class="exit-report-button" onclick="leaveChat(this)">❌
											대화 나가기</button>
									</div>
								</div>
							</div>
						</div>
					</c:when>
				</c:choose>
			</c:forEach>

			<script>
			// 채팅방 나가면 STATUS = 'N' 처리
				function leaveChat(button) {
			        const confirmLeave = confirm("대화방에서 나가시겠습니까?");
			        if (confirmLeave) {
			            let listChat = button.closest(".list-chat");
			            if (listChat) {
			                const chatRoomId = listChat.getAttribute("data-chat-room-id");
	
			                fetch("${contextPath}/chat/exit/" + chatRoomId, {
			                    method: "POST",
			                    headers: {
			                        "Content-Type": "application/json"
			                    }
			                });
			                // UI 상에서 채팅방 제거
			                listChat.remove();
			                alert("대화방을 나갔습니다.");
			            }
			        }
			    }
			
          // 프로필 이미지 누르면 그 사람 소개페이지로 이동
				function goToUserPage(userId) {
					// 예: /mypage/user123 으로 이동
					window.location.href = `/mypage/${userId}`;
				}
        	</script>
			<div class="chat-footer1"></div>
		</div>

		<script>
		// 왼쪽 채팅 클릭 시 해당하는 채팅방 채팅 오른쪽 채팅에 반영
		 const chatRooms = document.querySelectorAll(".list-chat");
		
		 const contextPath = "${pageContext.request.contextPath}";
		
		  chatRooms.forEach(chat => { // 각 채팅방 추출해서 chat에 할당
		  chat.addEventListener("click", function () {
		    // 각 채팅방 아이디(고유키) 얻어와서 할당
		    const chatUserNum = chat.getAttribute("data-chat-userNum");
		    const chatRoomId = chat.getAttribute("data-chat-room-id");
		    const chatRoomType = chat.getAttribute("data-chat-type");
		    
		    // 오픈채팅방 -> 오픈채팅방 제목, 거래채팅방 -> 거래채팅 상대방 닉네임
		    let chatRightTitle = null;
		    if(chatRoomType=="오픈채팅방"){
		    	chatRightTitle = chat.getAttribute("data-open-chat-room-name");
		    } else {
		    	chatRightTitle = chat.getAttribute("data-chat-nickname"); 
		    }
		    
		    console.log("채팅방 아이디 :", chatRoomId);
		    console.log("채팅방 유형 :", chatRoomType);
		    console.log("우측 채팅방 제목 :", chatRightTitle);
		    console.log("채팅하고 있는 상대방 아이디 :", chatUserNum);
		    
		      if (!chatRoomId) {
		          alert("chatRoomId를 찾을 수 없습니다.");
		          return;
		        }
		      
		      /* const name = chat.querySelector(".chatname").textContent; */
		
		      const chatHeader2 = document.querySelector(".chat-header2");
		      const chatContent2 = document.querySelector(".chat-content2");
		      
		      chatContent2.innerHTML = ""; // 기존 메시지 초기화
		      chatHeader2.childNodes[0].textContent = chatRightTitle;
		      
		      // 컨텍스트 경로 포함해서 요청
		      fetch("${contextPath}/chat/messages/" + chatRoomId)   
			    .then(res => {
			          if (!res.ok) throw new Error("메세지 생성 불가ㅠㅠ");
			          return res.json();
			        })
		        .then(messages => {
		          messages.forEach(msg => {
		            const newMessage = document.createElement("div");
		            newMessage.className = "chat-message";
		
		            newMessage.textContent = msg.chatContent;
		            chatContent2.appendChild(newMessage);
		          });
		        })
		        .catch(err => {
		          console.error("메시지 로딩 실패ㅠㅠ", err);
		        });
		    });
		  });
		</script>




		<!-- 오른쪽 채팅방 -->
		<div class="chatting-room">
			<div class="chat-header2">
				상대방 이름
				<!-- 클릭하면 판매자 or 구매자에 맞춰서 해당하는 기능 제공 창  -->
				<button class="ellipse-button" onclick="transactionService()">
					<b>+</b>
				</button>
				<div id="transMenu" class="trans-menu hidden">
					<button class="trans-option"
						onclick="moveToTransOptionByType('배송지 정보 입력')">배송지 정보 입력</button>
					<button class="trans-option"
						onclick="moveToTransOptionByType('배송 정상 수령')">배송 정상 수령</button>
					<button class="trans-option"
						onclick="moveToTransOptionByType('운송장 입력')">운송장 입력</button>
					<button class="trans-option"
						onclick="moveToTransOptionByType('계좌 정보 전송')">계좌 정보 전송</button>
					<button class="trans-option"
						onclick="moveToTransOptionByType('안전 결제')">안전 결제</button>
					<button class="trans-option"
						onclick="moveToTransOptionByType('사기 계좌 조회')">사기 계좌 조회</button>
					<button class="trans-option"
						onclick="moveToTransOptionByType('거래 완료')">거래 완료</button>

					<!-- 
	            나눔, 교환
	             - 구매자 기준 버튼 : 주소요청, 배송 정상 수령, 운송장 입력, 거래 완료
	             - 판매자 기준 버튼 : 주소요청, 배송 정상 수령, 운송장 입력, 거래 완료
	
	            대여, 경매
	             - 구매자 기준 버튼 : 안전결제(아이엠포트), 배송정상수령, 사기 계좌 조회(경찰청), 거래완료
	             - 판매자 기준 버튼 : 배송지 정보 입력, 운송장 입력, 계좌 정보 전송
	
	            오픈채팅방에는 해당 버튼 필요X
	          -->
					<script>
				// 배송지 정보 입력, 배송 정상 수령 등 버튼 누르면 해당하는 alert창 및 채팅방 생성
				  function moveToTransOptionByType(type) {
				    switch (type) {
				      case "운송장 입력":
				        openModal('shipping_Inform_Input');
				        break;
				      case "배송지 정보 입력":
				    	openModal('shipping_Address_Modal');
				    	break;
				      case "배송 정상 수령":
				        alert("배송을 정상적으로 수령했습니다.");
				        break;
				      case "계좌 정보 전송":
				    	openModal('account_Inform_Input');
					    break;
				      case "거래 완료":
				        alert("거래가 완료되었습니다. \n생성된 버튼을 눌러 상대방의 매너 점수를 평가해주세요.");
				        // 거래 완료되면 데이터 조작
				       	completeTransaction();
				        // 버튼 생성하고 모달 오픈
				        break;
				      case "사기 계좌 조회":
				        window.open("https://www.police.go.kr/www/security/cyber/cyber04.jsp", "_blank");
				        break;
				      case "안전 결제":
				        window.open("https://www.iamport.kr/", "_blank");
				        break;
				    }
				  }
				</script>
				</div>
			</div>

			<script>
			// 거래 완료 버튼 생성 및 모달 오픈
			function completeTransaction() {
				  const chatContent = document.querySelector('.chat-content2');

				  // 이미 버튼이 있다면 중복 생성 방지
				  if (chatContent.querySelector('.review-button')) return;

				  const messageWrapper = document.createElement('div');
				  messageWrapper.classList.add('message', 'system-message');

				  messageWrapper.innerHTML = `
				    <button class="review-button" onclick="openModal('manner_Review')">
				     후기 작성하기
				    </button>
				  `;
				  // 채팅창에 추가
				  chatContent.appendChild(messageWrapper);
				  // 스크롤 하단으로 이동
				  chatContent.scrollTop = chatContent.scrollHeight;
				}
			</script>


			<!-- ======================= 각 모달 기술 ======================= -->

			<!-- 매너 평가 모달 -->
			<div id="manner_Review" class="modal-overlay hidden">
				<div class="modal">
					<div class="close-button" onclick="closeModal('manner_Review')">×</div>
					<h2>매너 평가</h2>
					<p>
						거래가 정상적으로 완료되었습니다. <br> 상대방의 매너 점수를 평가해주세요!
					</p>
					<div class="user-info">
						<!-- 상대방 프로필 이미지 -->
						<div class="user-icon"></div>
						<div class="username">상대방 닉네임</div>
					</div>
					<div class="slider-container">
						<div id="tempDisplay" class="temp-indicator" style="left: 36%">
							🔥 <span id="tempValue">36°C</span>
						</div>
						<input type="range" id="slider" min="0" max="100" value="36">
					</div>

					<div class="feedback">상대방에게 후기를 남겨주세요!</div>
					<textarea class="feedback-input" id="reviewText"
						placeholder="후기 내용을 입력하세요"></textarea>

					<div class="btns">
						<button class="btn cancel" onclick="closeModal('manner_Review')">취소</button>
						<button class="btn confirm" onclick="submitReview()">확인</button>
						<!-- 확인 버튼 누르면 온도, 후기 내용 얻어짐 -->
					</div>
				</div>
			</div>

			<script>
				let hasSubmitted = false; // 이미 제출했는지 체크
			
		        const slider = document.getElementById("slider");
		        const tempDisplay = document.getElementById("tempDisplay");
		        const tempValue = document.getElementById("tempValue");
		
		        slider.addEventListener("input", function () {
		            const val = slider.value;
		            tempValue.textContent = `\${val}°C`;
				
		            const percent = (val - slider.min) / (slider.max - slider.min) * 100;
		            tempDisplay.style.left = `\${percent}%`; 
		
		            // 36.5 기준으로 아이콘 바뀜 
		            tempDisplay.innerHTML = (val >= 36.5 ? "🔥" : "❄️") + ` <span>\${val}°C</span>`;
		        });
		    </script>

			<script>
			// 매너 평가자, 매너 평가 당하는 사람 두명 지정해줘야 됨
			function submitReview() {
				closeModal('manner_Review');

				if (hasSubmitted) {
					alert("이미 후기를 제출하셨습니다.");
					return;
				}

				const sliderValue = parseInt(document.getElementById("slider").value);
				const reviewText = document.getElementById("reviewText").value.trim();

				console.log("매너 온도:", sliderValue);
				console.log("후기 내용:", reviewText);

				// POST 요청 보내기
				"${contextPath}/chat/exit/"
				fetch("${contextPath}/chat/insertManner/", {
					method: 'POST',
					headers: {
						'Content-Type': 'application/json'
					},
					body: JSON.stringify({
						sliderValue: sliderValue,
						reviewText: reviewText
					})
				})
				.then(response => {
					if (response.ok) {
						alert("후기가 등록되었습니다!");
					} else {
						alert("등록 실패");
					}
				})
				.catch(error => {
					console.error("에러 발생:", error);
				});

				hasSubmitted = true;
			}
			</script>

			<!-- 운송장 정보 입력 모달 -->
			<div class="modal-overlay" id="shipping_Inform_Input">
				<div class="modal-container">
					<button class="close-button"
						onclick="closeModal('shipping_Inform_Input')">×</button>
					<div class="truck-icon">🚚</div>
					<div class="title">운송장 정보 입력</div>
					<!-- 택배사 및 운송장 번호 저장 -->
					<select id="deliveryCompany">
						<option value="">택배사 선택</option>
						<option value="CJ대한통운">CJ대한통운</option>
						<option value="한진택배">한진택배</option>
						<option value="로젠택배">로젠택배</option>
						<option value="우체국">우체국</option>
						<option value="롯데택배">롯데택배</option>
					</select> <input type="text" id="trackingNumber"
						placeholder="운송장 번호 - 없이 입력">
					<button class="submit-button" id="submitShippingInfo">다음</button>
				</div>
			</div>

			<!-- 배송지 정보 입력 모달 -->
			<div class="modal-overlay" id="shipping_Address_Modal">
				<div class="modal-container">
					<div class="modal-header">
						<span class="title-sub">IT다 배송지 정보 입력창</span>
						<button class="close-button"
							onclick="closeModal('shipping_Address_Modal')">×</button>
					</div>

					<div class="modal-body">
						<div class="icon-section">🚚</div>
						<h2 class="main-title">배송지 정보 입력</h2>
						<p class="sub-title">
							<!-- 상품 제목 -->
							<br>(주)잇다
						</p>

						<form class="address-form">
							<label>받으시는 분</label> <input type="text" class="input" id="name"
								placeholder="받으시는 분 성함" /> <label>주소</label>
							<div class="address-zip">
								<input type="text" class="input" id="zipcode" placeholder="우편번호" />
								<button type="button" class="zip-btn"
									onclick="execDaumPostcode()">우편번호 찾기</button>
							</div>
							<input type="text" class="input disabled" id="address"
								placeholder="주소" disabled /> <input type="text" class="input"
								id="detailAddress" placeholder="상세 배송지 정보 입력" /> <label>휴대폰
								번호</label> <input type="text" class="input" id="phone"
								placeholder="휴대폰 번호 - 없이 입력" />
						</form>

						<button class="next-button" id="nextButton">다음</button>
					</div>
				</div>
			</div>

			<!-- 내 계좌 정보 입력 모달 -->
			<div id="account_Inform_Input" class="modal-overlay"
				style="display: none;">
				<div class="modal-box">
					<button class="close-button"
						onclick="closeModal('account_Inform_Input')">×</button>
					<div class="modal-header">IT다 결제창</div>

					<h2 class="modal-title">내 계좌 정보 입력</h2>
					<%-- <p class="item-desc">
						상품명<br> ${productName}
						<!-- 전달된 상품명 동적 표현 -->
					</p> --%>

					<input type="text" class="input-box"
						placeholder="상대방과 최종 합의된 가격을 기입해주세요." id="price" /> <select
						class="input-box" id="bank">
						<option disabled selected>은행선택</option>
						<option>신한은행</option>
						<option>국민은행</option>
						<option>카카오뱅크</option>
						<option>토스뱅크</option>
						<option>농협은행</option>
					</select> <input type="text" class="input-box" placeholder="계좌 입력"
						id="account" />
					<button class="submit-button" onclick="submitAccountInfo()">다음</button>
				</div>
			</div>

			<div class="chat-content2">
				<div class="chat-message" id="item-board">

					<!-- 아이템 소개부분 -->
					<!-- 상품 사진 누르면 상품 상세 조회사이트로 이동 -->
					<!-- 상품 상세 사이트에서 채팅방으로 직접 들어올테니 '거래 채팅방' 테이블통해 게시물 정보 추출해오자 -->
					<button class="item-button" onclick="goToUserPage('상품 상세 사이트 링크')">
						<img src="resources/image.png" alt="" width="150" height="150"
							style="border-radius: 20%;">
						<div class="item-description">
							<div class="item-title">
								<strong>상품명:</strong>
							</div>
							<!-- 게시글 제목 -->
							<div class="item-type">
								<strong>거래유형:</strong>
							</div>
							<!-- 거래 유형 -->
							<div class="item-price">
								<strong>가격:</strong>
							</div>
							<!-- 가격 -->
						</div>
					</button>
				</div>
				<div class="chat-message received">이건 상대방 메시지입니다.</div>
			</div>


			<div class="chat-footer2">
				<!-- 버튼 눌렀을 때 나올 메뉴 -->
				<!-- 실제 파일 업로드용 input (숨김 처리) -->
				<input type="file" id="imageInput" accept="image/*"
					style="display: none;" />
				<!-- 사용자가 누르게 될 버튼 -->
				<button class="ellipse-button" onclick="insertImg()">
					<b>+</b>
				</button>
				<input type="text" class="chat-input" placeholder="메시지를 입력하세요..." />
				<button class="send-button" onclick="sendMessage()">
					<b>전송</b>
				</button>


				<!-- =========================우측 채팅방 기능========================= -->
				<script>
                // 오른쪽 채팅창 헤더 +버튼 눌렀을 때 
                // 주소요청, 운송장 입력 등 거래 유형에 맞게 보여줌

                function transactionService() {
                    const menu = document.getElementById("transMenu");
                    menu.classList.toggle("hidden");
                }


                // 메세지 보내기 (AJAX 버전)
                function sendMessage() {
				    const input = document.querySelector('.chat-input');
				    const message = input.value;
				
				    if (!message) {
				        alert("메시지를 입력해주세요.");
				        return;
				    }
				
				    // AJAX로 서버에 메시지 전송
				    $.ajax({
				        type: 'POST',
				        url: '/itda/chat/sendMessage', // 실제 서버 API URL로 변경
				        data: {
				            chatContent: message,
				            chatRoomId: 11 // 이 값도 꼭 넘겨야 합니다 일단 11로 고정
				        },
				        success: function(response) {
				            // 서버 저장 성공 시 화면에 메시지 추가
				            const chatContent = document.querySelector('.chat-content2');
				
				            const newMessage = document.createElement('div');
				            newMessage.className = 'chat-message sent';
				            newMessage.textContent = message;
				
				            chatContent.appendChild(newMessage);
				            chatContent.scrollTop = chatContent.scrollHeight;
				
				            input.value = "";
				        },
				        error: function() {
				            alert("메시지 전송 실패");
				        }
				    });
				}
                
                
                // 오른쪽 채팅창 왼쪽 하단 이미지 첨부
                function insertImg() {
                    document.getElementById('imageInput').click();
                    // 숨겨진 input을 클릭
                }
            </script>
			</div>
		</div>
	</div>

	<!-- chat.js 참조 -->
	<script type="text/javascript"
		src="${contextPath}/resources/js/chat.js"></script>
</body>

</html>