// this is just the update var and the html because the original idea was not working

var/Updates={"
<html>
<head>
    <style>
                body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f0f0f0;
        }
        header {
            background-color: #333;
            color: white;
            padding: 10px 0;
            text-align: center;
        }
        main {
            margin: 20px;
        }
        h3, h4, p, ul, li {
        	margin-left:2em;
            color: #333;
        }
        h4 {
        	margin-bottom: 0;
            margin-top: 0;
            }
        h2 {
            margin-top: 2em;
        }
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            margin-bottom: 1em;
            background-color: white;
            padding: 10px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        #spoiler {
            display: none;
            border: 1px solid #6c0196;
            padding: 10px;
            margin-top: 10px;
        }
        #spoilerButton {
            margin-top: 10px;
            padding: 5px 10px;
            border: none;
            background-color: #ffffff;
            color: rgb(0, 0, 0);
            cursor: pointer;
        }
    </style>
    <script>
        function toggleSpoiler() {
            var spoiler = document.getElementById('spoiler');
            var spoilerButton = document.getElementById('spoilerButton');
            if (spoiler.style.display === 'none') {
                spoiler.style.display = 'block';
                spoilerButton.innerHTML = 'Hide';
            } else {
                spoiler.style.display = 'none';
                spoilerButton.innerHTML = 'Show';
            }
        }
    </script>
</head>
<body>
<h1>Current Updates</h1>
<h2>6/10-12/2023</h2>
<h2>Updates</h2>

<h3>Stats</h3>
<ul>
    <li><strong>Changes:</strong>
        <ul>
            <li>Stats now show true and stat modification values.</li>
        </ul>
    </li>
</ul>

<h3>Halfies</h3>
<ul>
    <li><strong>Nerfs:</strong>
        <ul>
            <li>Now receive 50% less of Super Saiyan power bonus.</li>
        </ul>
    </li>
</ul>

<h3>Majins</h3>
<ul>
    <li><strong>Nerfs:</strong>
        <ul>
            <li>No longer receive extra power per ascension.</li>
        </ul>
    </li>
</ul>

<h3>Spiritsword / Hybrid Strike</h3>
<ul>
    <li><strong>Changes:</strong>
        <ul>
            <li>Were not functioning properly, still potentially broken, with further adjustments needed.</li>
            <li>Hybrid passives are planned to be overhauled.</li>
        </ul>
    </li>
</ul>

<h3>Spirit Hand</h3>
<ul>
    <li><strong>Changes:</strong>
        <ul>
            <li>Damage calculation has been changed to min 1.1, max of For * 0.25 or 1.5.</li>
        </ul>
    </li>
</ul>

<h3>Sunlight/Moonlight/Atomic/Parana Burst</h3>
<ul>
    <li><strong>Changes:</strong>
        <ul>
            <li>Hybrid damage calculation has been changed to a minimum of 1.25, max of For * 0.5 or 2.</li>
        </ul>
    </li>
</ul>

<h3>Global</h3>
<ul>
    <li><strong>Changes:</strong>
        <ul>
            <li>The minimum damage that can be dealt is now 0.001, to prevent occurrences of 0 and negative numbers.</li>
        </ul>
    </li>
</ul>

<h3>Sagas</h3>
<ul>
    <li><strong>Additions:</strong>
        <ul>
            <li>Hero Saga added, including a new passive: Shonen Power.</li>
        </ul>
    </li>
</ul>

<h3>Shonen Power</h3>
<ul>
    <li><strong>Changes:</strong>
        <ul>
            <li>Able to set a rival and gain a bonus similar to Duelist when below 25% HP.</li>
            <li>Receive a bonus for each friend in party knocked out.</li>
            <li>Gain more damage/reduction the lower your health percentage.</li>
            <li>Gain more intimidation the more fatigue percentage you have.</li>
            <li>When active, gain 25% more strength/focus for every tick.</li>
            <li>Juggernaut equals tick/2.</li>
        </ul>
    </li>
</ul>

<h3>Races</h3>
<ul>
    <li><strong>Changes:</strong>
        <ul>
            <li>Humans no longer receive additional ascension / 20 to each stat.</li>
        </ul>
    </li>
</ul>

<h3>Saiyans</h3>
<ul>
    <li><strong>Nerfs:</strong>
        <ul>
            <li>Potential transformation values have been reduced for all Super Saiyan forms.</li>
            <li>SSJ1: From 30 to 15.</li>
            <li>SSJ2: From 50 to 30.</li>
            <li>SSJ3: From 70 to 45.</li>
            <li>SSJ4: From 100 to 60.</li>
            <li>Rage: From 100 to 75.</li>
        </ul>
    </li>
</ul>

<h3>Mech Changes</h3>
<ul>
    <li><strong>Changes:</strong>
        <ul>
            <li>Piloting prowess now has a proposed max of 10 ticks, although it can exceed this, it was designed to reach that as a human ascension 5 with KOB.</li>
            <li>When piloting a mech, your base changes to the mech's level if it is under that, otherwise you get 0.15 per mech level.</li>
            <li>You also get your original stat (this means your straight MOD from creation) * (Piloting Prowess 0.075), which means you will have 75% of your original mod at 10 prowess.</li>
        </ul>
    </li>
</ul>


<h2>6/8-9/2023</h2>
<h2>Updates</h2>

<h3>Soukutsu</h3>
<ul>
    <li><strong>Nerfs:</strong>
        <ul>
            <li>Damage multiplier has been reduced from 4 to 1.5.</li>
            <li>Attribute has been reduced from 2 to 1.</li>
        </ul>
    </li>
</ul>


<h3>Curbstomp</h3>
<ul>
    <li><strong>Nerfs:</strong>
        <ul>
            <li>Damage multiplier has been slightly reduced from 4 to 3.25.</li>
        </ul>
    </li>
</ul>

<h3>Instant Strikes</h3>
<ul>
    <li><strong>Changes:</strong>
        <ul>
            <li>Now deal 25% less damage for every hit after the first one. Example: Soukutso, which has two instant strikes, now deals 25% less damage with its extra hit.</li>
        </ul>
    </li>
</ul>

<h3>Get Dunked</h3>
<ul>
    <li><strong>Nerfs:</strong>
        <ul>
            <li>Dunker attribute has been reduced from 2 to 1.</li>
            <li>Damage multiplier has been decreased from 4 to 2.5.</li>
        </ul>
    </li>
</ul>

<h3>Six Grand Opening</h3>
<ul>
    <li><strong>Nerfs:</strong>
        <ul>
            <li>Damage multiplier has been reduced from 4 to 3.</li>
            <li>Dunker attribute has been reduced from 2 to 1.</li>
        </ul>
    </li>
</ul>

<h3>SkullCrusher</h3>
<ul>
    <li><strong>Changes:</strong>
        <ul>
            <li>Damage multiplier has been reduced from 6 to 3.</li>
            <li>InstantStrike attribute has been increased from 0 to 2.</li>
        </ul>
    </li>
</ul>

<h3>Kinshasa</h3>
<ul>
    <li><strong>Nerfs:</strong>
        <ul>
            <li>Damage multiplier has been slightly reduced from 2.5 to 2.</li>
        </ul>
    </li>
</ul>

<h3>Piston Kick</h3>
<ul>
    <li><strong>Nerfs:</strong>
        <ul>
            <li>Damage multiplier has been slightly reduced from 1.5 to 1.25.</li>
        </ul>
    </li>
</ul>

<h3>Melee Damage</h3>
<ul>
    <li><strong>Fixes and Adjustments:</strong>
        <ul>
            <li>Melee damage will be checked and potentially adjusted, as it's currently causing higher than expected numbers, doing 2% on average.</li>
        </ul>
    </li>
</ul>

<h3>Character Types: Jinchu and Vaizard</h3>
<ul>
    <li><strong>Fixes and Adjustments:</strong>
        <ul>
            <li>Have been made selectable for players to further customize their game experience.</li>
        </ul>
    </li>
</ul>




<h3>Gameplay Changes</h3>
<ul>
    <li>Strong Fist now provides 0.15 knockback multiplier and forces knockback. This enhances the impact of using this attack.</li>
    <li>The maximum duration of knockback is now set at 50 ticks to maintain the balance of gameplay.</li>
    <li>Knockback speed has been adjusted to better fit the game dynamics.</li>
    <li>The combination of trinity, five rings, and dual wield no longer suffers from fencing. However, this change might be reversed since it's subject to bias and further testing.</li>
    <li>Alterations have been made to the sequence in which the additional knockback from zornhau/weapon soul/kendo happens. It now occurs after a queue's addition/multiplication instead of before.</li>
    <li>Gate 8 can now only be used once, and the get-up action after using Gate 8 happens twice before ending.</li>
    <li>The knockback mechanism has been altered and might be less oppressive. It requires further testing to ensure it's neither too powerful nor too weak.</li>
</ul>

<h3>Adjustments and Fixes</h3>
<ul>
    <li>Zeal Saiyans no longer go into negative god ki, correcting a previously existing issue.</li>
    <li>The aging process no longer reduces power, which forms the basis of damage. This change simplifies the damage calculation process.</li>
    <li>The attribute "rpppower" no longer grants any power. Future updates will aim to remove this attribute even more.</li>
</ul>




     <h2>6/8/2023 Notes</h2>
        <p> MECH BROS ARE NOT UP, THEY ARE JUST ASS FOR SOME REASON, also nerfs</p>
    <h2>Changes</h2>
<h3>Knockback Mechanics</h3>
<ul>
  <li>Buff: Juggernaut now provides 0.1 knockback resistance per point, as it used to resist knockbacks previously. Given the recent changes to Juggernaut, it should be feasible for it to stack up to 3.</li>
</ul>
<h3>Launcher and Stun Mechanics</h3>
<ul>
  <li>Bug fix: Launcher cooldown no longer ticks down while in Roleplay Mode.</li>
  <li>Admins can now change the base time for stun immunity.</li>
</ul>
<h3>Nerfs</h3>
<ul>
  <li>Vaizard health no longer reduces stun duration by half.</li>
  <li>Oozaru now reduces stun time by one-fourth instead of half, prior to Juggernaut / Legendary Power / debuff immunity checks.</li>
  <li>Debuff immunity now reduces stun time by 75%, not 200% (0.75 per 1, not 2 per 1).</li>
  <li>Eldritch beings receive 0.25 debuff immunity per ascension, down from 1 per ascension.</li>
  <li>If an Infusion Alien chooses Infusion again, they now receive 0.5 debuff immunity, not 1.</li>
</ul>
<h4>Kamui ( Nerfs and Buffs )</h4>
<ul>
<li>Instead of stacking 0.2 God Ki, it now stacks 0.25. This reduces the number of procs needed from 5 to 4.</li>
<li>Health heal is now calculated as 100 * (1 - God Ki), meaning it decreases with each proc from 100, 75, 50, to 25.</li>
<li>Energy is now calculated similarly to health heal, i.e., 100 * (1 - God Ki).</li>
<li>The ability triggers when Health is 10 or less.</li>
</ul>
<h3>Buffs</h3>
    <ul><li>Mobile Suits now have 2 debuff immunity, up from 0.25. (subject to testing)</li>
</ul><br><br>

    <h2>6/7/2023 Notes</h2>
        <p> xP, still need to do skill/saga changes for testers</p>
    <h2>Changes</h2>
<h3>Knockback Mechanics</h3>
<ul>
  <li>Changed how knockback resistance works.</li>
      <li>'Giantform' now provides a 2x knockback multiplier, and 'Legendary Power' provides a knockback boost equivalent to LP * 0.5. This is because Giantform usually contains Legendary Power.</li>
      <li>Introduced a new passive called 'HeavyHitter', which replicates the functionality of 'Strongfist' and 'Atomic Karate'. These two styles are specifically called in the code and should remain unaffected for now, but they'll be removed and replaced by 'HeavyHitter' in a future update.</li>
      <li>'HeavyHitter' is a straight knockback multiplier, i.e., 1 corresponds to 100%, 2 corresponds to 200%, and so forth.</li>
      <li>When 'HeavyHitter' is active, knockbacks are always considered 'forced', which means they can't be stopped except by 'Desperation'.</li>
      <li>After applying 'HeavyHitter', the character's normal knockback multiplier is added. If the result exceeds the global maximum (currently set at 5), it's reduced to match the maximum.</li>
  <li>Knockback resistance mechanics have been modified as well.

      <li>'Giantform' and 'Legendary Power' are now the only abilities that provide knockback resistance.(Vaizard health no longer does)</li>
      <li>Each tick, 'Legendary Power' gains 0.25 knockback resistance and 'Giantform' gains 0.5. This is because 'Giantform' can go up to 1, whereas 'Legendary Power' cannot. These resistances can stack.</li>
      <li>The resistance is added to the character's knockback resistance and then multiplied by distance, typically resulting in a small decimal value.</li>
      <li>The only in-game ability capable of completely halting a knockback (aside from 'Desperation' and 'KOB') is 'Legendary Power', which has a 50% chance per tick to stop a knockback.</li>
</ul>
<h3>Launchers</h3>
<ul>
  <li>Fixed a bug with launchers that allowed them to stack up to infinite seconds due to a missing limit.</li>
      <li>Launchers are now added to a game loop and have a static lockout time of 10 seconds (modifiable by other variables) and a maximum launch time of 4 seconds. Admins in-game can modify these two variables.</li>
      <li>When you're launched, a timer is set, and an additional 4 seconds (or whatever the current setting is) are added. If the world's uptime surpasses this value, you can no longer be launched for longer, and the function will exit.</li>
      <li>After being launched, you're "grounded" for the duration of the lockout time. The additional modifiers for 'Juggernaut' and 'Legendary Power' are calculated as follows: 1 + (Juggernaut * 0.25) + (Legendary Power * 0.25).</li>
</ul>
<h3>Stuns</h3>
<ul>
  <li>Legendary Power and Juggernaut now reduce stun time by an amount equal to 1 + (Legendary Power * 0.5) + (Juggernaut * 0.25).</li>
      <li>The stun duration is divided by the value.</li>
      <li>Characters also become immune to stuns for 30 seconds multiplied by the same modifier.</li>
</ul>
<h3>ShonenPower</h3>
<ul>
  <li>Added 'ShonenPower' as a non-functional variable name for future development.
    <ul>
      <li>It will become active when the value is 10 or lower, but will deactivate between 15-25 to prevent reuse.</li>
      <li>It will allow the setting of a rival, which will provide bonuses when ShonenPower is active.</li>
      <li>The ability will provide increased damage for each downed party member.</li>
      <li>Damage and reduction will increase based on the percentage of remaining health, with a minor increase per tick (likely less than 1x pure damage or reduction per full tick).</li>
      <li>Intimidation will increase with fatigue percentage.</li>
      <li>Strength and For will increase by 1.25x per tick.</li>
      <li>Juggernaut's value will be equal to tick / 2.</li>
    </ul>
  </li>
</ul>
<h3>Minor Changes</h3>
<ul>
  <li>Added an 'soIgnore' option. When checked, the system will bypass checks for identical IP addresses, allowing people sharing an internet connection to trade items and interact more easily.</li>
</ul>
<h3>Outstanding Bugs</h3>
<ul>
  <li>Blobs are currently bugged when players relog, causing them to be transported to a dark place.</li>
</ul>


    <h2>6/6/2023 Notes</h2>
        <p> i looked at intimidation</p>
    <h2>Changes</h2>
        <h3>Global</h3>
            <ul><li>Intimidation was not doing anything for damage, it was just for spiking your dopamine. <br>
            An experimental new feature is in where it does something for both reduction and damage. <br>
            <code> Firstly, we get the defender's intimidation and then the attacker's intimidation and ignore(a ratio)<br>
            After this, we see if the defender is in Saiyan Soul and the defender's Target is not, if so, they get their targets intimidation.<br>
            (subject to change if some autistic person targets 1 guy and fights untargetted)<br>
            Once we have the defender's intimidation as the current val we check to see if its over 1, then we subtract it<br>
            This subtraction is ( DefIntimi - (DefIntim*IgnoreRatio) ) which results in a percentage of the defender's intimidation being subtracted.<br>
            Now, we check if the current val (after ignore) is more than the attacker's intimidaiton, if so we set the number to (negative) (val - atkIntim) / 10<br>
            This results in 1 for each 10 points of difference, but as a negative which will later reduce damage.<br>
            The same thing is done if the val is less than the atk's only the equation is (atkIntim - val) / 10.<br>
            We return value to a variable called trueMult which is used later.<br>
            After a whole boat load(like 300+ lines of code) of more damage stuff, pure dmg/red is added to the trueMult.<br>
            AFTER EVEN MORE CODE...<br>
            If True Mult is over 0 we take the damageVal and multiply it by 1+(0.1*TrueMult) so a 6 trueMult would be 1.6<br>
            Now, on the flip side if it is under 0 we take the damageVal and divide it by 1+((-0.1*TrueMult) so a -6 trueMult would be 1.6<br>
            These results are 0.5 * 1.6 = 0.8 and 0.5 / 1.6 = 0.3125 respectively. <br>
            The last part is old code :) </code></li></ul>
            <ul><li> Blobs are bugged on relog, sends u to a dark place</ul></li>
    <h2>6/5/2023 Notes</h2>
        <p> majin cool :3</p>
    <h2>Changes</h2>
        <h3>Sagas</h3>
            <h4>King of braves</h4>
               <ul><li>KoB got a 2/3x intimidation when under 1 health & were in Genesic Brave - > 1 + (10-Health)/10 OR 2 + (10-Health)/10 intimidation mult while under 10 health & in buff</li></ul>
                
        <h3>Race: Majin</h3>
            <h4>Balance Changes:</h4>
    <ul>
        <li>Majins no longer deal 25% more wounds to others and themselves.</li>
        <li>Majins no longer take 25% more fatigue.</li>
        <li>Majins can be slowed (& crippled) again.</li>
        <li>Majins no longer nullify shear at over 3 ascension.</li>
        <li>Majins now divide shear by 1 + ascension.</li>
        <li>Majins gain pure damage/reduction from their potential depending on their class (changed from gaining pot / 10 pure reduction).</li>
    </ul>
    <h4>Class Ascension 1:</h4>
    <h3>Fat</h3>
    <ul>
        <li>Lard = ++END, +DEF -SPD</li>
        <li>Protect = ++DEF, +END, +SPD</li>
        <li>Fluid Form</li>
    </ul>
    <h3>Super</h3>
    <ul>
        <li>Flexible = +ALL STATS</li>
        <li>Focused = ++TO 3 STATS</li>
        <li>Giant Form</li>
    </ul>
    <h3>Unhinged</h3>
    <ul>
        <li>Carnage = -END, -DEF, ++SPD, ++OFF</li>
        <li>Destruction = -END, -DEF, ++STR, ++OFF</li>
        <li>Unhinged Form (DEF/END closer to 0 = more speed)</li>
    </ul>
    <h4>Mechanics:</h4>
    <ul>
        <li><strong>Absorb:</strong> Planning on it doing a tax to the person absorbed or a maim, no kill, but the user gets to pick a passive from the person they absorbed.</li>
        <li><strong>Blobs:</strong> Fat Majin starts dropping pieces of himself when he gets low (scales with ascension), they can only drop X blobs per med, there's a % chance every hit below the threshold to drop them. Blobs heal health and provide buffs that have passives on them.</li>
        <li><strong>Ascension:</strong> Soon they will have 5 max.</li>
        <li><strong>Global Changes:</strong> Changed it so evil races/secrets with holy mod will be considered good (might change later, depends on feedback).</li>
    </ul>
    <h4>Unchanged Features:</h4>
    <ul>
        <li>Static Walk</li>
        <li>Timeless (Doesn't age)</li>
        <li>Majins still can't be poisoned(?)</li>
        <li>Void Defense</li>
        <li>Regeneration</li>
    </ul>
    <h4>Class Stats:</h4>
    <p>Majins no longer get 0.75 per click of stat in creation, now equivalent to other races. Majins now have new class distributions.</p>
    <h3>Innocent</h3>
    <ul>
        <li>STR: 0.75</li>
        <li>END: 2</li>
        <li>SPD: 0.5</li>
        <li>Force: 1.25</li>
        <li>Off: 1</li>
        <li>Def: 1.5</li>
    </ul>
    <h3>Unhinged</h3>
    <ul>
        <li>STR: 2</li>
        <li>END: 0.5</li>
        <li>SPD: 1.75</li>
        <li>Force: 1.25</li>
        <li>Off: 1.25</li>
        <li>Def: 0.75</li>
    </ul>
    <h4>Unchanged Stats:</h4>
    <ul>
        <li>Regen: 3</li>
        <li>Recov: 5</li>
        <li>Anger: 2</li>
        <li>Learning: 2</li>
        <li>Intellect: 0.25</li>
        <li>Imagination: 4</li>
    </ul>
    <h4>Scents:</h4>
    <ul>
        <li>Innocent - Chocolate</li>
        <li>Super - Gum</li>
        <li>Unhinged - Sweets & Sugars</li>
    </ul>
    <h4>To Be Done:</h4>
    <ul>
        <li>Look at Intimidation & Power</li>
        <li>Change Absorb</li>
    </ul>
    <h3>Notes:</h3>
    <ul>
        <li>Majins can have Sagas (needs testing).</li>
        <li>Majins regeneration (combat verb) race modifier is 2, the next highest being Namekians at 1.5.</li>
        <li>Majins regenerate 20% faster in med and get an additional 20% per ascension. 0.2 + 0.2 (needs testing).</li>
    </ul>
    <h2 id="bug-fixes">Bug Fixes</h2>
            <h3>Dividing Driver</h3>
            <ul>
            	<li>Is no longer crashing the game when used without a target.</li>
                <li>Blobs properly delete themselves at the end of their buff.</li>
            </ul>
    <h2>6/4/2023 Notes</h2>
    <p>oh brother...</p>
        <h2 id="changes">Changes</h2>
        	<h3>Global</h3>
            	<ul><li>Leak has a global divider now, so things that cause leak (being in a trans and hitting people) will be less, it is set to 2.5 atm, after testing Golden Form it doesn't seem to drain too much. Different Transformation drains are going to be implemented later.
        		</li><li>No more drowning.</li>
                <li>GLOBAL DAMAGE MOD FROM 1 -> 0.75 (25% less damage)</li>
                <li>Power control, sense & zanzo are given at 1 potential.</li>
                <li>Hakai has been disabled</li>
                <li>Credits are now Dollars</li>
                </ul>
            <h3>Skills</h3>
                <ul>
                    <h4>Regeneration</h4>
                    <li>
                    StableHeal 0 -> 1 (Regen stat doesn't affect it)<br>
                    HealthHeal 0.5 -> Variable (in notes)<br>
                    CoolDown 600(Normal)/300(Werewolf)/150(Majin) -> Once a Fight<br>
                    <s>Ticks 20</s>Ticks 30 -> Variable (in notes)<br>
                    EnergyCost 0 -> TotalHeal/2
                    FatigueCost 15 -> TotalHeal
                    <br><small>Notes:</small>
                    <br><code> Certain races have additonal healing, Majin has 100% more, Demon has 25% more and Namekian has 50% more.
                    <br>The total healing done by Regeneration will be <s>2% + 2% per ascension + RaceBoon/10 + 0.15% per 1 missing health.</s> 1.5% + 1.5% per ascenion + RaceBoon/10 + 0.12% per 1 missing health.
                    <br>The total ticks it takes will be <s>20</s>30 / (1 + Ascension * RaceBoon). A Asc 1 Majin would heal at 10 ticks, while having no racial boon would be 20.
                    <br>For admins: Editting the skill and editting altered to 1 will disable the auto updating of HealthHeal/LimitTimer, so if you want to make a regen skill that instantly heals 50 or something, that's how.
                    
                    </code>
                </li></ul>
                <ul>
                <h4>Jecht Shot</h4>
                    <li>
                    Distance 40 -> 65<br>
                    Deflectable 1 -> 0 <br>
                    MultiHit 0 -> 4 (bug fix)<br>
                </li></ul>
                <ul>
                <h4>Blaster Shell</h4>
                    <li>
                    Distance 15 -> 25<br>
                    Dodgable 1 -> 0 (Pending testing)<br>
                    AccMult 1 -> 3<br>
                    Cooldown 120 -> 40<br>
                </li></ul>
                <ul>
                <h4>Spirt Gun</h4>
                    <li>
                   	DmgMult 1 -> 1.25<br>
                    Str/ForRate 1 -> 1.25 (25% more from str/for)<br>
                    FatigueCost 0 -> 1/4th Total Cost<br>
                </li></ul>
                <ul>
                <h4>Nova Strike</h4>
                    <li>
                    DmgMult 1 -> 0.8<br>
                   	Rounds 20 -> 10 (how long it lasts)<br>
                </li></ul>
                <ul>
                <h4>Death Saucer</h4>
                    <li>
                    DmgMult 2.5 -> 1.2<br>
                    Blasts 2 -> 4<br>
                    Crippling 0 -> 1<br>
                    MainStrike 1.25 -> 0<br>
                    Speed 2 -> 1.45 (lower is faster)<br>
                    Delay 3 -> 2.25 (lower is faster)<br>
                    Cooldown 150 -> <s>50</s>60<br>
                </li></ul>
                <ul>
				<h4>Hellzone Grenade</h4>
                    <li>
                    DmgMult 0.25 -> 0.2<br>
                    Blasts 20 -> 15<br>
                    ZoneX/Y 5 -> 3 (the blasts spawn in a 3x3, not 5x5)<br>
                    Hover 15 -> 7 (wait half as long)<br>
                    Speed 0.5 -> 0.25 (twice as fast)<br>
                    Cooldown 150 -> 120<br>
                </li></ul>
                <ul>
                <h4>Buster Barrage</h4>
                    <li>
                    DmgMult 0.5 -> 0.25<br>
                    Blasts 20 -> 10<br>
                    ZoneX/Y 0 -> 4<br>
                    Hover 0 -> 3 (these 2 vars give it some delay before it starts chasing u down)<br> 
                    Delay 0.5 -> 0.85 (lower is faster)<br>
                    Cooldown 150 -> 120<br>
                </li></ul>
                <ul>
                <h4>Kikoho - Needs Testing, im tired</h4>
                    <li>
                    DmgMult 10 -> 8<br>
                    Health/Wound Cost 10 -> 6<br>
                    Launcher 2 -> 1<br>
                    Stunner 2 -> 0.5<br>
                    WindUp 0.5 -> 1.5<br>
                </li></ul>
                <ul>
                <h4>Makosen</h4>
                    <li>
                    DmgMult 0.1 -> 4<br>
                    Distance 30 -> 50<br>
                    Blasts 10 -> 1<br>
                    EnergyCost 10->15<br>
                    Radius 1->2<br>
                    Stream/Variation 5/24 -> 0/0 (this makes buster barrage n old makosen rapid fire)<br>
                    Cooldown 150 -> 60<br>
                    Homing 0 -> 1<br>
                    LosesHoming 0<br>
                    KnockBack 0 -> 1<br>
                    Explode 0 -> 1<br>
                    Speed 0.5 -> 0.8<br>
                    Delay 1 -> 1.45<br>
                    AccMult 1 -> 3<br>
                    IconSize 1.3 -> 3.4<br>
                </li></ul>
                <h4>Corkscrew Blow</h4>
                <ul>
                    <li>
                   Name: CockscrewBlow -> Corkscrew Blow<br>
                   DamageMult: 0.75 -> 0.4 <br>
                   Duration: 20 -> 10<br>
                   KBAdd: 5 -> 3 <br>
                </li>
                </ul>
                <h4>Dempsey Roll</h4>
                <ul>
                    <li>
                   DamageMult: 0.5 -> 0.3<br>
                   AccMult: 2.5 -> 3 <br>
                   Duration: 5 -> 8 <br>
                   Combo: 5 -> 4<br>
                </li>
                </ul>
                <h4>Gale Strike</h4>
                <ul>
                    <li>
                   DmgMult: 2.5 -> 1.8 (Reduced)<br>
                   EnergyCost: 5 -> 10 (Increased)
                </li>
                </ul>
<h4>Gale Strike Projectile</h4>
                <ul>
                    <li>
                   DamageMult: 0.5 -> 0.3 (Reduced)<br>
                   MultiHit: 10 -> 8 (Reduced)
                </li>
                </ul>
                <h4>Kiai</h4>
                <ul>
                    <li>
                PROPOSED CHANGES (NOT IN / NOT SURE WHAT GALION WILL CHANGE)<br>
                   StrOffense: 0 -> 0.75 (Increased to 75%)<br>
                   ForOffense: 1 -> 0.75 (Decreased by 25%)<br>
                   DamageMult: 1 -> 0.6 (Decreased by 40%)<br>
                   Rounds: (None previously) -> 3 (Newly added)<br>
                   Knockback: 10 -> 3 (Decreased by 70%)<br>
                   Stunner: 3 -> 1.5 (Decreased by 50%)<br>
                   CHANGES<br>
                   Uses AfterImageStrike on Use (Cleanses Stun)<br>
                </li>
                </ul>
                <ul>
                <h4>Wolf Fang Fist -- also needs testing</h4>
                    <li>
                    StrOffense 1 -> 0.5 (50% of str as bonus mult)<br>
                    Rounds 20 -> 10<br>
                    Stunner 1 -> 0.5<br>
                    Launcher 1 -> 2<br>
                    Cooldown 150 -> 160 <br>
                </li>
                </ul>
            <h3>Races</h3>
                <ul>
                    <li>Dijin changed to Majin per request of management.
                </ul>

        <h2 id="bug-fixes">Bug Fixes</h2>
            <h3>Str Offense wasn't working</h3>
            <ul>
            	<li>Autohits were only taking the value of 1 from str offense, not allowing for lower modifiers or higher. they now can take lower and higher values.</li>
            </ul>

        <h2 id="buffs">Buffs</h2>
            (These changes are part of the loop refactor mentioned in Misc. aka they are not live yet)
            <h3>Saiyan</h3>
            	<ul>
                <li>
                	Super Saiyan will drain out at between 30% energy at 5 mastery and 0 at 75+ mastery
                <br><small>Example:</small>
                    <br><code> SSJMastery of 15 results in a revert at 26% Energy. 
                    <br>SSJMastery of 55 results in a revert at 9% Energy.</code>
                </li>
                </ul>
            <h3>Changeling</h3>
                <ul>
                <li>
                Golden Form will drain out at between 30% energy at 0 mastery and 1% at 99, 0% at 100
                <br><small>Example:</small>
                <br><code> Mastery of 15 results in a revert at 25% Energy. 
                    <br>Mastery of 55 results in a revert at 13% Energy.
                    <br>Mastery of 90 results in a revert at 5% Energy.</code>
            </li>
            </ul>


        <h2 id="miscellaneous">Miscellaneous</h2>
        <ul>
            <li>Main Loop is being refactored, trying to minimize lag. - Not Live</li>
            <li>New update html page is being worked on.</li>
            <li>Update, etc. can be clicked before making a character.</li>
        </ul>

        <h1>Old Patch Notes</h1>
            <button id="spoilerButton" onclick="toggleSpoiler()">Show</button>
            <div id="spoiler">
                [file2text('Updatenotes/oldNotes.txt')]
            </div>
</body>
</html>

"}

