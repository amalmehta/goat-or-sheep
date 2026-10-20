// The quiz itself: questions, results and scoring. No page code, so the Swift tests can
// load this file in JavaScriptCore and check it against Sources/GoatOrSheepKit/Quiz.swift.
const QUESTIONS = [
  ["Your friends pick a restaurant you don't love. You…", [
    ["Pitch a better place and book it", "goat"],
    ["Go. It's about the company", "sheep"],
    ["Go, but order something off-menu", "goat"],
    ["Read the reviews everyone else is reading", "sheep"]]],
  ["A new app everyone's talking about comes out. You…", [
    ["Download it because everyone did", "sheep"],
    ["Already tried it last month", "goat"],
    ["Wait and see if it sticks", "sheep"],
    ["Skip it. You like your own setup", "goat"]]],
  ["Your ideal weekend is…", [
    ["A group trip someone else planned", "sheep"],
    ["A solo hike somewhere steep", "goat"],
    ["Whatever the group decides", "sheep"],
    ["A project you've been obsessing over", "goat"]]],
  ["In a meeting, your idea gets ignored. You…", [
    ["Bring it up again, louder", "goat"],
    ["Let it go. The team has momentum", "sheep"],
    ["Build a prototype and show them", "goat"],
    ["Back the idea that's winning", "sheep"]]],
  ["Rules are…", [
    ["There for a reason", "sheep"],
    ["Suggestions", "goat"],
    ["What keeps things fair", "sheep"],
    ["Mostly for other people", "goat"]]],
  ["At a buffet you…", [
    ["Try one of everything, weird stuff first", "goat"],
    ["Follow the line and take what's popular", "sheep"],
    ["Go straight for dessert", "goat"],
    ["Stick to what you know", "sheep"]]],
  ["Your phone's home screen is…", [
    ["Untouched since the day you got it", "sheep"],
    ["A system only you understand", "goat"],
    ["The same apps as your friends", "sheep"],
    ["One page, nothing extra", "goat"]]],
  ["You're lost in a new city. You…", [
    ["Follow the crowd. They probably know", "sheep"],
    ["Pick a direction and commit", "goat"],
    ["Ask someone for directions", "sheep"],
    ["Climb something to get a better view", "goat"]]],
  ["Your manager announces a plan you think will fail. You…", [
    ["Say so in the meeting, with your reasons", "goat"],
    ["Stay quiet and hope someone else says it", "sheep"],
    ["Ask for ten minutes with them afterwards", "goat"],
    ["Go along with it. They probably know something you don't", "sheep"]]],
  ["Someone takes credit for your work. You…", [
    ["Correct the record, politely but clearly", "goat"],
    ["Let it slide. It'll even out", "sheep"],
    ["Vent to a friend instead", "sheep"],
    ["Tell them, then tell your manager", "goat"]]],
  ["The meeting ends with “Any questions?” You…", [
    ["Ask the one everyone's thinking", "goat"],
    ["Stay quiet and look it up later", "sheep"],
    ["Wait to see if anyone else goes first", "sheep"],
    ["Raise your hand before you lose your nerve", "goat"]]],
  ["Your parents have already decided what's best for you. You…", [
    ["Agree out loud, disagree in your head", "sheep"],
    ["Tell them calmly that you see it differently", "goat"],
    ["Let it go. It's not worth the fight", "sheep"],
    ["Make your own call and explain it later", "goat"]]],
  ["At a family dinner, everyone agrees on something you don't. You…", [
    ["Nod along to keep the peace", "sheep"],
    ["Share your view, even if the room goes quiet", "goat"],
    ["Save it for the car ride home", "sheep"],
    ["Ask a question that makes them think twice", "goat"]]],
  ["A friend makes a joke that crosses a line. You…", [
    ["Laugh along so it isn't awkward", "sheep"],
    ["Tell them it wasn't funny", "goat"],
    ["Change the subject", "sheep"],
    ["Pull them aside later and say it bothered you", "goat"]]],
  ["Pick a motto.", [
    ["Safety in numbers", "sheep"],
    ["Why walk when you can climb?", "goat"],
    ["Go with the flow", "sheep"],
    ["Eat first, ask questions later", "goat"]]],
];

const ANIMALS = {
  goat: { name: "Goat", emoji: "🐐",
    blurb: "You pick your own path, even when it's a cliff face. Curious, stubborn in the best way, and willing to try anything once, including the thing nobody else will eat." },
  sheep: { name: "Sheep", emoji: "🐑",
    blurb: "You know there's strength in the flock. Calm, loyal, and easy to be around, you keep the group together and rarely end up stuck on a ledge." },
};

// With an odd number of questions there's never a tie.
function score(p) {
  const goats = p.filter(a => a === "goat").length;
  return { goats, total: p.length, animal: goats * 2 > p.length ? "goat" : "sheep" };
}
