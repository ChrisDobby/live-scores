resource "aws_sns_topic" "scorecard-updated" {
  name = "scorecard-updated"
}

resource "aws_sns_topic" "game-over" {
  name = "game-over"
}
