# @import i18n
# @import html
# @import enums
class KoreanLanguagePack
{
	# @type Dict<string, string>
	_pack = Dict();

	# @return Dict<string, string>
	function Load()
	{
		return self._pack;
	}

	# @return string
	function Language()
	{
		return I18n.KoreanLanguage;
	}

	function Init()
	{
		self._pack.Set("general.beast.lowercase", "짐승 거인");
		self._pack.Set("general.beast.uppercase", "짐승 거인");
		self._pack.Set("general.beast.titlecase", "짐승 거인");
		self._pack.Set("general.beast.sentencecase", "짐승 거인");

		self._pack.Set("chat.start", "동료를 죽여라, 지크를 멈춰라.");
		self._pack.Set("chat.soldier_died", "병사 {0}가 죽었다.");

		self._pack.Set("info.beast_type.pitcher", "투수
		투석을 주 공격 방식으로 사용하며, 비교적 느린 이동 속도와 가장 낮은 체력을 가지고 있습니다.");
		self._pack.Set("info.beast_type.warrior", "전사
		근접 및 원거리 공격 능력을 모두 갖추었으며, 비교적 빠른 이동 속도와 가장 높은 체력을 가지고 있습니다.");
		self._pack.Set("info.beast_type.assassin", "암살자
		주로 근접 전투를 공격 방식으로 사용하며, 매우 빠른 이동 속도와 비교적 낮은 체력을 가지고 있습니다.");
		self._pack.Set("info.special_events.stronger", "동료들이 더욱 강력한 거인이 되었습니다!!");
		self._pack.Set("info.special_events.last_chance", "보급품 없이 루비콘 강을 건너십시오!");

		self._pack.Set("ui.info.title", "게임 방법");
		self._pack.Set("ui.info.rules", "규칙 확인");
		self._pack.Set("ui.info.switch_weapon", "무기 교체");
		self._pack.Set("ui.info.beast_type", "짐승 거인 타입");
		self._pack.Set("ui.info.special_events", "특수 이벤트");
		self._pack.Set("ui.info.levi_mode", "리바이 모드-활성화");

		self._pack.Set("guide.mao", "OrangeCat橘猫");
		self._pack.Set("guide.1", "{0} 의 {1} 맵에 오신 것을 환영합니다!");
		self._pack.Set("guide.2", "처음 플레이할 때 주의할 점은 다음과 같습니다:");
		self._pack.Set("guide.3", "게임 방법");
		self._pack.Set("guide.4", "제한 시간 내에 거인을 처치하고, 거인이 5마리 이하로 줄면, {0} 이 등장합니다.");
		self._pack.Set("guide.5", "그럼 게임 종료 조건은: {0} 이 죽거나, 모든 유저가 죽는 것입니다.");

		self._pack.Set("guide.recommendations.header", "추천");
		self._pack.Set("guide.recommendations.skill", "스킬-Spin1");
		self._pack.Set("guide.recommendations.weapon", "장비-검 또는 뇌창 중 택 1");
		self._pack.Set("guide.recommendations.difficulty", "난이도-기행종");
		self._pack.Set("guide.recommendations.settings.endless", "무한 리스폰-비활성화");
		self._pack.Set("guide.recommendations.settings.invincible", "스폰 무적 시간-15초");

		self._pack.Set("guide.description.header", "맵 설명");
		self._pack.Set("guide.description.body", "플레이어 거인의 공격 속도와 이동 속도는 매우 빠르며, 스태미너가 무제한입니다.
뇌창을 사용하면 가스를 더 많이 얻을 수 있습니다.
대인/신형 사용 금지
댄스/에렌/애니 스킬 사용 금지, 보급과 전투 시간이 제한되어 있습니다.
일부 건물 및 보급 지점은 파괴될 수 있습니다.
일정 킬 점수 이상을 획득한 플레이어는 20초 동안 모든 거인의 타겟이 됩니다.
		리바이 모드가 꺼져 있을 때 플레이어의 체력은 100으로 고정되며, 짐승 거인의 공격에 면역되지 않습니다.");

		self._pack.Set("guide.mode_settings.header", "모드 셋팅");
		self._pack.Set("guide.mode_settings.1", "거인 수");
		self._pack.Set("guide.mode_settings.2", "칼날 수");
		self._pack.Set("guide.mode_settings.3", "가스 양");
		self._pack.Set("guide.mode_settings.4", "칼날 투척 사용이 허용되는지 여부");
		self._pack.Set("guide.mode_settings.5", "칼날을 사용하는 모든 플레이어의 스킬을 Spin1으로 설정하십시오.");
		self._pack.Set("guide.mode_settings.6", "돌려베기 1/2/3 스킬 쿨타임 없음.");
		self._pack.Set("guide.mode_settings.7", "돌려베기 1/2/3 강화 여부");
		self._pack.Set("guide.mode_settings.8", "리바이 모드: 돌려베기 스킬 쿨타임 없음.
거인의 목 뒷부분을 자동으로 조준함.
		짐승 거인의 공격에 피해 없음.");
		self._pack.Set("guide.mode_settings.9", "모든 거인의 타겟이 되기 위한 최소 킬 점수");
		self._pack.Set("guide.mode_settings.10", "제한 시간 (짐승 거인이 등장할 때까지)");
		self._pack.Set("guide.mode_settings.11", "짐승 거인 타입: 투수 / 전사 / 암살자");
		self._pack.Set("guide.mode_settings.12", "더욱 강력한 거인");
		self._pack.Set("guide.mode_settings.13", "강화된 거인의 강조 여부");
		self._pack.Set("guide.mode_settings.14", "보급없이 루비콘 강 건너기");
		self._pack.Set("guide.mode_settings.15", "플레이어 강조 여부");
		self._pack.Set("guide.mode_settings.16", "게임 음악");
		self._pack.Set("guide.mode_settings.17", "플레이어 거인의 체력");

		self._pack.Set("guide.staff.header", "STAFF");
		self._pack.Set("guide.staff.yy", "天格 绅士君");
		self._pack.Set("guide.staff.xx", "Callis");
		self._pack.Set("guide.staff.hongyao", "Hongyao");
		self._pack.Set("guide.staff.kun", "君");
		self._pack.Set("guide.staff.levi", "Levi");
		self._pack.Set("guide.staff.hikari", "Hikari");
		self._pack.Set("guide.staff.ring", "Ring");
		self._pack.Set("guide.staff.han", "ㅎㄱ");
		self._pack.Set("guide.staff.jagerente", "Jagerente");

		self._pack.Set("guide.staff.yy.role", "짐승 거인 모델");
		self._pack.Set("guide.staff.xx.role", "짐승 거인 애니메이션");
		self._pack.Set("guide.staff.hongyao.role", "짐승 거인 로직");
		self._pack.Set("guide.staff.kun_levi.role", "커스텀 로직 전문가");
		self._pack.Set("guide.staff.hikari.role", "최적화 및 번역가");
		self._pack.Set("guide.staff.ring.role", "리바이 모드 로직");
		self._pack.Set("guide.staff.han.role", "번역가");
		self._pack.Set("guide.staff.jagerente.role", "멀티 로컬라이제이션 지원, 리팩토링 및 최적화");

		self._pack.Set("guide.about.header", "Tea party에 관하여");
		self._pack.Set("guide.about.contacts", "컨텐츠 정보");
		self._pack.Set("guide.about.1", "茶话会TeaParty는 중국에 있는 기술 길드입니다.");
		self._pack.Set("guide.about.2", "우리는 커스텀 로직, ASO, 레이싱 및 기타 AOTTG 게임 콘텐츠에 대해 이야기 합니다.");
		self._pack.Set("guide.about.3", "저희는 최근에 몇 가지 커스텀 콘텐츠를 제작하거나 최적화하는 작업을 하고 있습니다.");
		self._pack.Set("guide.about.4", "저희 팀은 그것들에 대해 약간의 수정과 번역 작업을 담당하고 있습니다.");
		self._pack.Set("guide.about.5", "중국의 훌륭한 커스텀 맵들도 여기서도 등장할 수 있도록 말입니다!");
		self._pack.Set("guide.about.qq_group", "QQ 그룹: 662494094");
		self._pack.Set("guide.about.discord", "디스코드: 茶话会TeaParty (https://discord.gg/RdhPSUAMSt)");

		self._pack.Set("ui.goal.kill_titans", "{0} 마리의 거인들을 죽여야 합니다, 그렇지 않으면 지크가 숲을 빠져나갈 것입니다.");
		self._pack.Set("ui.goal.kill_beast", HTML.Size(HTML.Color("짐승 거인", ColorEnum.Brown), 25) + " 이 등장했습니다, 그를 죽이세요!");
		self._pack.Set("ui.goal.kill_titans_time", "{0} 마리의 거인들을 죽여야 합니다, 그렇지 않으면 지크가 숲을 빠져나갈 것입니다. | 남은시간: {1}초");

		self._pack.Set("ui.lose", "이것이 평범한 병사와 아커만의 차이입니다..");
		self._pack.Set("ui.lose.2", "지크를 막을 사람은 이제 아무도 없습니다..");

		self._pack.Set("ui.titans_target", "거인들의 표적: {0}");

		self._pack.Set("dialogue.name.zeke", "지크 예거");
		self._pack.Set("dialogue.name.levi", "리바이 아커만");

		self._pack.Set("dialogue.a.1", "으아아아아아아!!!");
		self._pack.Set("dialogue.a.2", "잠깐...");
		self._pack.Set("dialogue.a.3", "잘 있어라, 리바이… 네 병사들은 잘못한 게 없어. 다만 조금 더 커졌을 뿐이야.");
		self._pack.Set("dialogue.a.4", "그 하나 때문에 그들을 산산조각 내겠다고 하진 않겠지?");
		self._pack.Set("dialogue.a.5", "지크의 척수액이 와인에 섞여 있었다고…?!
대체 언제부터 준비 해놨던 거지...?
전혀 그런 흔적이 없었는데..
		아무도 경직되지 않았어... 거짓말이었나?");
		self._pack.Set("dialogue.a.6", "망할, 빠르구만! 몸놀림이 예사롭지 않아… 이것도 지크의 소행인가!
		바리스..!! 너희들… 아직 거기 있는 거냐?");

		self._pack.Set("dialogue.b.1", "결별이다...
		끝내 서로를 믿지 못했으니...");
		self._pack.Set("dialogue.b.2", "전 세계의 모든 세력이 이 섬에 모이려 하고 있어.
		그게 무슨 뜻인지 이해를 못 하고 있어.");
		self._pack.Set("dialogue.b.3", "자신들한테는 힘과 시간, 선택권을 가지고 있다고 생각했지.
		그건 모두 어리석은 믿음이다...");
		self._pack.Set("dialogue.b.4", "뭐 내 진의를 털어놓은 들 이해해줄 턱이 없겠다마는...");
		self._pack.Set("dialogue.b.5", "에렌, 내가 이 숲을 벗어나면
		금방 네 곁으로 갈거다!");

		self._pack.Set("dialogue.c.ui.1", "{0} <color=#FF0000> 이 전장에 나타났습니다!!</color>
		투석을 피하려면 나무 뒤에 숨으십시오!");
		self._pack.Set("dialogue.c.1", "뭐냐고! 진짜!!!");
		self._pack.Set("dialogue.c.2", "어디로 간 거냐!? 리바이!
네 부하들은 어디 갔냐!
		설마 죽인 거냐? 불쌍하게도!!");
		self._pack.Set("dialogue.c.3", "뭣?! 나뭇가지...?!");
		self._pack.Set("dialogue.c.4", "넌 너무 절박했어, 수염 면상아.
		그저 앉아서 독서만 하면 된건데, 대체 뭘 믿고 내게서 도망칠 수 있다고 생각한거지?");
		self._pack.Set("dialogue.c.5", "나한테서 도망칠 수 있을 거라고 생각했나?
		부하들을 거인으로 만들면 내가 동료들을 못 죽일 줄 알았던 거냐?");
		self._pack.Set("dialogue.c.6", "아마 너는 모를 거야...
		우리가 얼마나 많은 동료들을 죽여야 했는지!!");

		self._pack.Set("dialogue.d.chat", "희생된 동료들이 우리를 응시하고 있습니다...");
		self._pack.Set("dialogue.d.1", "작별이다, 리바이.");
		self._pack.Set("dialogue.d.2", "에렌, 내가 곧 그 곳으로 가마!!");

		self._pack.Set("dialogue.e.chat", "결국 당신은 그가 될 수 없었습니다...");
		self._pack.Set("dialogue.e.1", "저 녀석이 나를 따라잡지 못하는 것 같군.
		여기서 묻혀라, 리바이.");
		self._pack.Set("dialogue.e.2", "에렌과 나의 위대한 대의는... 그 아무도 막을 수 없어!!");

		# self._pack.Set("dialogue.f.chat", "何も捨てることができない人には、何も変えることはできない...");
		self._pack.Set("dialogue.f.chat", "아무것도 버릴 수 없는 사람은 아무것도 바꿀 수 없다.");
		self._pack.Set("dialogue.f.1", "안돼에!!!!!!!");
		self._pack.Set("dialogue.f.2", "어이, 수염 면상.
너 좀 봐... 썩고, 더럽고, 추악한 놈 같으니라고. 그래도 걱정 마. 널 죽이진 않을 거야.
		아직은 말이지");

		self._pack.Set("interaction.chat.1", "
지크를 보면 짜증이 나…
——OrangeCat橘猫

누군가는 항상 뭔가를 하는 데 앞장서야 하지 않겠어?
——Hikari

먀옹~
		——君");

		self._pack.Set("interaction.chat.2", "
일하는 중...
——Hongyao

커스텀 로직을 진지하게 공부하는 티파티의 새로운 멤버입니다.
——Ring

AVE 83.
		——Jagerente");

		self._pack.Set("ui.zeke_defeated", "지크 예거가 패배했습니다! 인류의 승리!");
	}
}
